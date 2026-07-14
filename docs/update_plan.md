# TideView — Migration Plan: Supabase Backend + OAuth2

**Status:** Revisi ke-2 — pivot dari PocketBase/PocketHost/Oracle ke **Supabase** (gratis, tanpa kartu kredit)
**File ini menggantikan total:** `tideview-pocketbase-migration-plan.md`, `fase-0-tutorial-pockethost-setup.md`, `fase-0-tutorial-oracle-cloud-setup.md` — ketiganya sudah obsolete, abaikan.

**Alasan pivot:** PocketHost sudah berbayar penuh ($9.99/bulan min). Self-host di Oracle Cloud (opsi gratis selamanya) tetap butuh kartu kredit buat verifikasi akun. Supabase adalah satu-satunya opsi backend-as-a-service yang genuinely gratis **tanpa kartu kredit sama sekali**, dan justru realtime-nya pakai **WebSocket asli** (bukan SSE seperti PocketBase) — lebih deket ke ekspektasi awal kamu.

**Keputusan yang sudah difinalkan:**
- Backend: **Supabase** (Postgres + Auth + Realtime + Edge Functions, semua dalam satu platform, dikelola Supabase — gak perlu server sendiri)
- Auth provider: Google + GitHub (built-in di Supabase Auth)
- Data lama: fresh start, tidak ada migrasi otomatis
- Mode akses: guest browsing diizinkan untuk lihat market data; login wajib untuk watchlist/alert/custom category
- Notifikasi alert: tetap local-only (device-side check via Workmanager) untuk fase ini

---

## 1. Kenapa Supabase Cocok (dan Apa yang Berubah)

| Aspek | PocketBase (rencana lama) | Supabase (rencana baru) |
|---|---|---|
| Database | SQLite | **PostgreSQL** — lebih powerful, relasi/query lebih matang |
| Realtime | SSE (satu arah) | **WebSocket asli** (Realtime via Postgres logical replication) |
| Row-level security | "API Rules" (filter expression) | **Row Level Security (RLS)** — fitur native Postgres, lebih standard |
| Server-side logic | `pb_hooks` (goja JS) | **Edge Functions** (Deno/TypeScript, full-featured) + Postgres trigger buat logic DB-only |
| Auth | Collection `users` custom | **Supabase Auth** — OAuth Google/GitHub tinggal aktifin di dashboard |
| Hosting | Perlu server sendiri (VPS) | **Fully managed**, gak ada server buat di-maintain |
| Biaya | $9.99/bulan (PocketHost) atau butuh CC (self-host) | **$0, tanpa kartu kredit** |
| Limit gratis | Tergantung VPS | 500MB database, 50.000 MAU, 1GB file storage — auto-pause kalau 7 hari gak ada aktivitas |

---

## 2. Arsitektur Final

```
Flutter App
  │
  ├── WebSocket (Realtime, dua arah)
  │     supabase.from('assets').stream() → update harga real-time
  │
  ├── REST/RPC (CRUD via Supabase client library)
  │     auth, watchlist, price_alerts, watchlist_categories, profiles
  │
  ▼
Supabase Project (project-ref.supabase.co)
  │
  ├── Edge Function `sync-markets` (Deno/TypeScript)
  │     dijadwalkan via Cron Trigger tiap 15 menit
  │     fetch Binance → upsert ke table `assets`
  │     fetch Frankfurter → upsert ke table `assets`
  │     fetch Finnhub (key disimpan sbg Supabase Secret) → upsert ke table `assets`
  │     fetch exchangerate-api → update `profiles.exchange_rate`
  │
  ├── Postgres Trigger `check_alerts` (plpgsql, native DB — gak perlu Edge Function terpisah)
  │     jalan otomatis tiap kali row `assets` di-update
  │     evaluasi `price_alerts` yang aktif, set isActive = false kalau triggered
  │
  ├── PostgreSQL Database
  │     assets, chart_cache, profiles, user_watchlist,
  │     price_alerts, watchlist_categories
  │     + Row Level Security policies per table
  │
  └── Supabase Auth
        Google OAuth  ← Google Cloud Console
        GitHub OAuth  ← GitHub Developer Settings

Flutter App (local, tetap dipertahankan)
  ├── Isar          → mirror cache offline-first + sumber data widget
  └── Workmanager   → trigger refresh saat app closed (hit Supabase REST, bukan 3 API eksternal)
```

---

## 3. Schema Database (PostgreSQL)

### Table `assets` — shared, read-only untuk client
```sql
create table assets (
  id uuid primary key default gen_random_uuid(),
  symbol text unique not null,
  name text not null,
  current_price numeric not null,
  price_change_24h numeric not null,
  image text,
  market_type text not null check (market_type in ('crypto', 'forex', 'stocks')),
  updated_at timestamptz not null default now()
);

alter table assets enable row level security;

create policy "Public read access"
  on assets for select
  using (true);

-- WAJIB: project Supabase yang dibuat setelah 30 Mei 2026 defaultnya TIDAK
-- otomatis expose table baru ke Data API. RLS policy di atas gak akan
-- ke-enforce sama sekali kalau grant ini kelewat -- request bakal ditolak
-- duluan di level grant, sebelum sempat dicek RLS-nya.
grant select on assets to anon, authenticated;

-- Sengaja TIDAK ada policy insert/update/delete untuk role authenticated/anon.
-- Cuma service_role (dipakai Edge Function) yang bisa nulis, karena service_role
-- otomatis bypass RLS.
```

### Table `chart_cache` — shared, read-only

**Catatan optimasi:** karena `cache_key` unique + upsert, table ini gak numpuk tanpa batas seiring waktu — tapi tiap row (`prices_json`) tetap perlu di-cap jumlah data point-nya di sisi Edge Function sebelum insert (misal maks 90 titik data harian per series), biar satu row gak membengkak dan bikin total database ngelewatin limit 500MB lebih cepat dari seharusnya.

```sql
create table chart_cache (
  id uuid primary key default gen_random_uuid(),
  cache_key text unique not null,
  prices_json jsonb not null,
  updated_at timestamptz not null default now()
);

alter table chart_cache enable row level security;

create policy "Public read access"
  on chart_cache for select
  using (true);

grant select on chart_cache to anon, authenticated;
```

### Table `profiles` — extend data user, 1:1 dengan `auth.users`
```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  base_currency text not null default 'USD',
  sync_interval_minutes int not null default 15,
  widget_asset_symbol text not null default 'BTC',
  exchange_rate numeric not null default 1,
  theme_mode text not null default 'system',
  accent_color text,
  language_code text not null default 'en'
);

alter table profiles enable row level security;

create policy "Users manage own profile"
  on profiles for all
  using (auth.uid() = id);

grant select, insert, update, delete on profiles to authenticated;

-- Trigger: otomatis bikin row profiles begitu user baru signup
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

### Table `user_watchlist` — per-user
```sql
create table user_watchlist (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  asset_id uuid not null references assets(id) on delete cascade,
  is_watchlisted boolean not null default false,
  custom_categories jsonb not null default '[]',
  sort_order int not null default 0,
  unique (user_id, asset_id)
);

alter table user_watchlist enable row level security;

create policy "Users manage own watchlist"
  on user_watchlist for all
  using (auth.uid() = user_id);

grant select, insert, update, delete on user_watchlist to authenticated;
```

### Table `price_alerts` — per-user
```sql
create table price_alerts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  symbol text not null,
  target_price numeric not null,
  is_above boolean not null,
  is_active boolean not null default true
);

alter table price_alerts enable row level security;

create policy "Users manage own alerts"
  on price_alerts for all
  using (auth.uid() = user_id);

grant select, insert, update, delete on price_alerts to authenticated;
```

### Table `watchlist_categories` — per-user
```sql
create table watchlist_categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  sort_order int not null default 0
);

alter table watchlist_categories enable row level security;

create policy "Users manage own categories"
  on watchlist_categories for all
  using (auth.uid() = user_id);

grant select, insert, update, delete on watchlist_categories to authenticated;
```

### Trigger evaluasi price alert (native Postgres, gak perlu Edge Function)
```sql
create function public.check_price_alerts()
returns trigger as $$
begin
  update price_alerts
  set is_active = false
  where symbol = new.symbol
    and is_active = true
    and (
      (is_above = true and new.current_price >= target_price)
      or
      (is_above = false and new.current_price <= target_price)
    );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_asset_price_updated
  after update on assets
  for each row execute procedure public.check_price_alerts();
```

---

## 4. Fase 0 — Setup Supabase & Schema

**Tugas:**
1. Buat project Supabase (tanpa CC), catat `Project URL` dan `anon key`.
2. Jalankan semua SQL di atas lewat **SQL Editor** di dashboard.
3. Verifikasi RLS jalan benar — test pakai 2 akun dummy (lihat tutorial terpisah).
4. Catat `service_role key` (buat dipakai Edge Function nanti) — **JANGAN PERNAH taruh key ini di client/Flutter**, ini bypass semua RLS.

**Checkpoint:** Semua table ada, RLS aktif dan teruji, trigger `check_price_alerts` jalan (test manual update `assets.current_price` lalu cek `price_alerts` ke-update).

*(Detail step-by-step di file `fase-0-tutorial-supabase-setup.md`.)*

---

## 5. Fase 1 — Edge Function `sync-markets`

Ditulis dalam TypeScript (Deno runtime), dideploy via Supabase CLI. **Logic di bawah ini adaptasi langsung dari `crypto_repository.dart`, `stocks_repository.dart`, dan `forex_repository.dart` yang sudah terbukti jalan di app kamu** — bukan ditulis ulang dari nol, cuma dipindah dari Dart/client ke TypeScript/server, plus 3 optimasi baru (batching CoinGecko, stagger+market-hours Finnhub, cap ukuran chart_cache).

```typescript
// supabase/functions/sync-markets/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // service role, bypass RLS
)

// --- 1. CRYPTO: CoinGecko, 1 request buat sampai 250 coin ---
// (menggantikan pola lama: fetch Binance ticker/24hr, filter USDT pairs, sort by volume)
async function syncCrypto() {
  const res = await fetch(
    'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=false'
  )
  const coins = await res.json()

  const rows = coins.map((c: any) => ({
    symbol: c.symbol.toUpperCase(),
    name: c.name,
    current_price: c.current_price,
    price_change_24h: c.price_change_percentage_24h ?? 0,
    image: c.image,               // field ini akhirnya kepake, gak dead code lagi
    market_type: 'crypto',
  }))

  await supabase.from('assets').upsert(rows, { onConflict: 'symbol' })
}

// --- 2. FOREX: Frankfurter, sama persis kayak forex_repository.dart lama ---
async function syncForex() {
  const res = await fetch('https://api.frankfurter.dev/v1/latest?from=USD')
  const data = await res.json()

  // daftar friendly name currency -- dipindah dari _getFriendlyName di forex_repository.dart lama
  const currencyNames: Record<string, string> = {
    EUR: 'Euro', GBP: 'British Pound', JPY: 'Japanese Yen',
    IDR: 'Indonesian Rupiah', AUD: 'Australian Dollar', /* ...selebihnya dari mapping lama */
  }

  const rows = Object.entries(data.rates).map(([symbol, rate]) => ({
    symbol,
    name: currencyNames[symbol] ?? symbol,
    current_price: rate as number,
    price_change_24h: 0,  // Frankfurter gak kasih 24h change, sama kayak sebelumnya
    market_type: 'forex',
  }))

  await supabase.from('assets').upsert(rows, { onConflict: 'symbol' })
}

// --- 3. STOCKS: Finnhub, stagger + skip di luar jam bursa ---
// (menggantikan pola lama: Future.wait 50 request bersamaan -- itu yang bikin rawan rate limit)
function isMarketHours(): boolean {
  const nowUtc = new Date()
  const nyHour = (nowUtc.getUTCHours() - 5 + 24) % 24  // kasar, gak handle DST, cukup buat guard awal
  const day = nowUtc.getUTCDay()
  const isWeekday = day >= 1 && day <= 5
  return isWeekday && nyHour >= 9 && nyHour < 16
}

async function syncStocks() {
  if (!isMarketHours()) {
    console.log('Di luar jam bursa, skip sync stocks kali ini')
    return
  }

  const finnhubKey = Deno.env.get('FINNHUB_API_KEY')
  // symbol list & friendly name -- dipindah persis dari _stockNames di stocks_repository.dart lama
  const stockSymbols = ['AAPL', 'MSFT', 'GOOGL', /* ...selebihnya dari daftar 50 lama */]

  const rows = []
  for (const symbol of stockSymbols) {
    const res = await fetch(`https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${finnhubKey}`)
    const q = await res.json()
    rows.push({
      symbol,
      name: symbol, // ganti pakai _getFriendlyName mapping lama kalau mau nama lengkap
      current_price: q.c,
      price_change_24h: q.dp ?? 0,
      market_type: 'stocks',
    })
    await new Promise((r) => setTimeout(r, 1000)) // delay 1 detik antar call, hindari burst
  }

  await supabase.from('assets').upsert(rows, { onConflict: 'symbol' })
}

Deno.serve(async (_req) => {
  await syncCrypto()
  await syncForex()
  await syncStocks()

  return new Response(JSON.stringify({ success: true, syncedAt: new Date().toISOString() }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

**Catatan penting:**
- `FINNHUB_API_KEY` disimpan sebagai **Supabase Secret** (Dashboard → Edge Functions → Secrets), bukan hardcoded.
- Jadwalkan eksekusi tiap 15 menit lewat **Dashboard → Edge Functions → sync-markets → Cron** (`*/15 * * * *`), atau via `pg_cron` yang manggil `net.http_post` ke URL function ini.
- Trigger `check_price_alerts` otomatis jalan tiap kali function ini upsert row `assets` — gak perlu Edge Function terpisah buat cek alert.
- Daftar `stockSymbols` dan `currencyNames` di atas cuma contoh sebagian — pas implementasi beneran, saya salin lengkap dari `_stockNames`/`_getFriendlyName` di `stocks_repository.dart` dan `forex_repository.dart` kamu biar konsisten sama yang udah jalan.
- `isMarketHours()` di atas itu perhitungan kasar (asumsi UTC-5 tanpa handle daylight saving) — cukup buat guard awal biar gak sync sia-sia, tapi kalau mau presisi nanti bisa pakai library timezone Deno yang lebih proper.

**Checkpoint:** table `assets` ke-update otomatis tiap 15 menit (stocks cuma pas jam bursa), bisa diverifikasi dari **Table Editor** di dashboard tanpa Flutter app nyala.

### Edge Function ke-2: `get-chart-data` (on-demand, bukan cron)

Beda pola dari `sync-markets` — ini dipanggil **on-demand** oleh Flutter client pas user buka asset detail screen, bukan dijadwalkan. Adaptasi dari `fetchHistoricalData()` di ketiga repository lama (Binance klines buat crypto, Yahoo Finance unofficial buat forex & stocks), dengan cache 30 menit yang sekarang disimpan di table `chart_cache` (Postgres) bukan Isar lokal.

Dipanggil dari Flutter:
```
GET https://<project-ref>.supabase.co/functions/v1/get-chart-data?symbol=BTC&marketType=crypto&timeframe=1M
```

Server cek `chart_cache` dulu (kalau ada dan umurnya <30 menit, langsung balikin itu tanpa hit API eksternal lagi — persis logic caching yang lama), kalau cache kosong/basi baru fetch ke sumber sesuai `marketType` dan upsert ke `chart_cache`.

**Checkpoint:** panggil endpoint di atas manual (browser/curl) buat beberapa symbol berbeda, pastikan response pertama `fromCache: false` (fetch baru), panggil lagi dalam 30 menit dan pastikan `fromCache: true` (dari cache, gak hit API eksternal lagi).

---

## 6. Fase 2 — Ganti Data Layer di Flutter

**Dependency baru:**
```yaml
dependencies:
  supabase_flutter: ^latest
```

**File yang diubah:**

| File lama | Perubahan |
|---|---|
| `lib/core/repositories/crypto_repository.dart` | Ganti isi: `supabase.from('assets').select().eq('market_type', 'crypto')` |
| `lib/core/repositories/forex_repository.dart` | Sama, filter `market_type = forex` |
| `lib/core/repositories/stocks_repository.dart` | Sama, filter `market_type = stocks` — **hapus dependency ke `Env.finnhubApiKey`** |
| `lib/core/providers/api_provider.dart` | Tambah provider yang dengerin `supabase.from('assets').stream(primaryKey: ['id'])`, tiap event masuk → tulis ke Isar + invalidate provider terkait |
| `lib/core/services/background_service.dart` | Sederhanakan: cuma `supabase.from('assets').select()` sekali, tulis ke Isar, update widget |
| `lib/core/usecases/market_sync_usecase.dart` | Kemungkinan besar **bisa dihapus total** |
| `lib/core/env/env.dart`, `env.g.dart` | **Hapus** — key Finnhub gak lagi dibutuhkan di client |

**Setup Supabase client** (`lib/main.dart`, ditambah sebelum `runApp`):
```dart
await Supabase.initialize(
  url: 'https://<project-ref>.supabase.co',
  anonKey: '<anon-key-kamu>',  // ini AMAN ditaruh di client, beda dari service_role key
);

final supabase = Supabase.instance.client;
```

**Realtime subscription — WAJIB di-filter, jangan subscribe ke seluruh table:**
```dart
// SALAH -- ini nyerap kuota 2 juta message/bulan dengan cepat kalau user makin banyak:
// supabase.from('assets').stream(primaryKey: ['id']).listen(...)

// BENAR -- subscribe cuma ke symbol yang lagi ditampilkan di layar (watchlist/dashboard user):
final visibleSymbols = ['BTC', 'ETH', 'USD/IDR']; // ambil dari watchlist/screen aktif
supabase
    .from('assets')
    .stream(primaryKey: ['id'])
    .inFilter('symbol', visibleSymbols)
    .listen((data) {
      // tulis ke Isar, invalidate provider
    });
```
Dispose/cancel subscription ini tiap kali user pindah screen atau app masuk background, jangan biarin nyala terus — ini juga ngirit budget 200 koneksi concurrent di free tier.

**Checkpoint:** App nampilin harga dari Supabase, update realtime kelihatan tanpa refresh manual, tetap bisa offline (data dari Isar).

---

## 7. Fase 3 — Auth Google + GitHub

**Setup eksternal:**
1. **Google Cloud Console** → OAuth Client ID, tipe *Web application*, Authorized redirect URI = `https://<project-ref>.supabase.co/auth/v1/callback`
2. **GitHub Developer Settings** → OAuth App baru, Authorization callback URL = pattern yang sama
3. **Supabase Dashboard → Authentication → Providers** → aktifkan Google & GitHub, masukkan Client ID + Secret masing-masing
4. **Supabase Dashboard → Authentication → URL Configuration** → tambah Redirect URL buat mobile app: `io.tideview.app://login-callback` (custom scheme, perlu didaftarkan juga di `AndroidManifest.xml`)

**Kode Flutter:**
```dart
Future<void> loginWithGoogle() async {
  await supabase.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: 'io.tideview.app://login-callback',
  );
}

Future<void> loginWithGithub() async {
  await supabase.auth.signInWithOAuth(
    OAuthProvider.github,
    redirectTo: 'io.tideview.app://login-callback',
  );
}
```

**AndroidManifest.xml — tambah intent-filter baru** (terpisah dari deep link `tideview://asset` yang sudah ada):
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="io.tideview.app" android:host="login-callback" />
</intent-filter>
```

**UX flow:** sama seperti rencana sebelumnya — guest browsing buat lihat market data, login wajib buat watchlist/alert/kategori.

**Checkpoint:** login Google/GitHub jalan, redirect balik ke app sukses, `profiles` row otomatis kebuat (dari trigger `handle_new_user`), watchlist/alert nyangkut ke akun.

---

## 8. Fase 4 — Cleanup Teknis

- [ ] Hapus `lib/core/usecases/market_sync_usecase.dart` (kalau obsolete)
- [ ] Hapus `lib/core/env/` (`env.dart`, `env.g.dart`)
- [ ] Hapus dependency `envied`, `envied_generator` dari `pubspec.yaml`
- [ ] Hapus `test/widget_test.dart` boilerplate lama
- [ ] **Fix `android/app/build.gradle.kts`** — release keystore proper, `isMinifyEnabled = true`, ProGuard rules
- [ ] Tambah intent-filter OAuth callback di `AndroidManifest.xml` (lihat Fase 3)

---

## 9. Urutan Eksekusi

```
Fase 0 (Setup Supabase)  → checkpoint: schema + RLS teruji, trigger alert jalan
Fase 1 (Edge Function)   → checkpoint: assets ke-update otomatis tiap 15 menit
Fase 2 (Flutter data)    → checkpoint: app nampilin data Supabase, realtime & offline jalan
Fase 3 (Auth)            → checkpoint: login Google/GitHub jalan, data per-user konsisten
Fase 4 (Cleanup)         → checkpoint: build release APK signed proper, minified
```

---

## 10. Optimasi & Budget Free Tier

Free tier Supabase (per Juli 2026): **500MB database, 5GB egress/bulan, 500.000 Edge Function invocation/bulan, 200 koneksi realtime concurrent, 2 juta message realtime/bulan, auto-pause 7 hari inaktivitas**. Ini strategi konkret biar tetap di dalam batas itu sambil app tetap berkembang:

| Area | Risiko kalau dibiarkan | Mitigasi |
|---|---|---|
| CoinGecko quota | 50 request/sync kalau naif | 1 request/sync pakai `/coins/markets` (batch sampai 250 coin) — ~2.880 call/bulan, jauh di bawah limit 10.000 |
| Finnhub quota | Burst 50 request bersamaan | Stagger 1 detik antar request + skip sync di luar jam bursa (`isMarketHours()`) |
| Database 500MB | `chart_cache` bengkak gak terkontrol | Cap jumlah data point per series di Edge Function sebelum insert, upsert (bukan insert terus) |
| Database 500MB | `price_alerts` numpuk alert yang udah triggered | Cron cleanup, hapus alert `is_active = false` yang lebih dari 30 hari |
| Egress 5GB/bulan | Query `select=*` boros payload | Selalu spesifik kolom yang dipakai (`select=symbol,name,current_price,...`) |
| Realtime 2 juta message/bulan | Subscribe ke seluruh table `assets` | Filter subscription cuma ke symbol yang lagi ditampilkan (lihat Fase 2), dispose pas app background |
| Realtime 200 koneksi | Koneksi nyala terus walau app di background | Dispose stream pas `AppLifecycleState.paused`, reconnect pas resume |
| Auto-pause 7 hari | Project mati kalau vakum lama | Cron `sync-markets` tiap 15 menit kemungkinan besar cukup jadi "aktivitas" — tambah 1 lapis pengaman: GitHub Actions gratis yang ping health-check endpoint tiap 3 hari |
| Monitoring | Kelewat limit tanpa sadar | Set usage alert di Dashboard → Settings → Billing (Supabase kirim email di 80% dari tiap limit) |

**Prinsip umum:** Edge Function invocation (2.880/bulan buat cron aja) jauh di bawah limit 500.000, jadi bukan concern utama. Yang paling perlu dipantau ketat itu **Realtime message** dan **Database size**, karena keduanya scale langsung sama jumlah user aktif — kalau nanti user beneran ramai, itu duluan yang kena batas sebelum yang lain.

---

## 11. Risiko / Hal yang Perlu Dipantau

- **Auto-pause 7 hari inaktivitas** (free tier) — project Supabase pause otomatis kalau gak ada request 7 hari. Selama Edge Function cron jalan tiap 15 menit, ini kemungkinan besar gak kejadian di production. Cuma perlu diwaspadai kalau development-nya sempat vakum lama (>7 hari gak disentuh).
- **Limit 500MB database** — cukup buat data kita (harga, watchlist, alert — semuanya teks/angka kecil), tapi kalau `chart_cache` diisi historical data buat banyak symbol & timeframe, perlu ada housekeeping (hapus cache lama) biar gak membengkak.
- **2 project limit di free tier** — kalau nanti butuh environment staging terpisah dari production, perlu diatur strategi (misal 1 project buat dev+staging pakai schema terpisah, 1 project khusus production).
- **Yahoo Finance unofficial endpoint** (masih dipakai buat historical chart) — sekarang dipanggil dari Edge Function, bukan dari device, jadi kalau diblokir cukup ganti di satu tempat.