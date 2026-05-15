# QA Final Audit v1.0.1

## Audit Scope

- Dokumen yang diperiksa: `docs/QA/QA_SCAN_REPORT.md`, `docs/QA/QA_IMPLEMENTATION_CHECKLIST.md`, `docs/QA/QA_EXECUTIVE_SUMMARY.md`
- Fokus kode: seluruh folder `lib/`, khususnya `lib/core/` dan `lib/core/repositories/`
- Audit meliputi: Isar singleton, null safety repos, Isar efisiensi, timer invalidation, Finnhub API validation, background service protection, data statis/mock, dan API key leakage.

---

## Matriks Kelulusan

| Kategori | Item                                    | Status         | Catatan singkat                                                                                                                                                                                                                                  |
| -------- | --------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Critical | C1 - IsarService Singleton              | FAIL / PARTIAL | `api_provider.dart` singleton ada, tetapi banyak instansiasi `IsarService()` langsung di `alert_provider.dart`, `exchange_rate_provider.dart`, `feature/*`, `shared/widgets/*`, dan screen lain. Global singleton tidak dijaga secara konsisten. |
| Critical | C2 - marketSyncProvider reuse           | PASS           | `marketSyncProvider` sudah di-cache sebagai singleton global.                                                                                                                                                                                    |
| Critical | C3 - null safety di repos               | PARTIAL        | `crypto_repository.dart` dan `forex_repository.dart` diperbaiki; `stocks_repository.dart` masih perlu validasi type lebih ketat untuk respons Finnhub.                                                                                           |
| Critical | C4 - empty catch StocksRepo             | PASS           | error logging sudah ada untuk setiap `top15Stocks` fetch.                                                                                                                                                                                        |
| Critical | C5 - Forex JSON validation              | PASS           | `fetchForexMarkets()` kini validasi struktur JSON dan rate > 0.                                                                                                                                                                                  |
| Critical | C6 - background service protection      | PASS           | `background_service.dart` terbungkus `try/catch`, transaksi Isar diproteksi.                                                                                                                                                                     |
| Critical | C7 - Isar/alert efficiency              | PASS           | `MarketSyncUseCase` dan background sync sekarang menggunakan `assetMap` O(1) lookup dan batch update `putAll`.                                                                                                                                   |
| High     | H1 - Theme provider Isar reuse          | PASS           | `theme_provider.dart` lazy-inits satu instance.                                                                                                                                                                                                  |
| High     | H2 - AlertProvider listener race        | PASS           | sudah fetch awal sebelum `watchLazy` subscribe.                                                                                                                                                                                                  |
| High     | H3 - IsarService.openDB null safety     | PASS           | `openDB()` memeriksa `Isar.getInstance()` null sebelum buka.                                                                                                                                                                                     |
| High     | H4 - MarketSyncUseCase fallback         | PASS           | fallback cache/empty data handling ada di `getCryptoData()`.                                                                                                                                                                                     |
| High     | H5 - writeTxn try/catch                 | PASS           | `IsarService` semua write transaction dibungkus `try/catch`.                                                                                                                                                                                     |
| High     | H6 - background service alert batching  | PASS           | `putAll` digunakan, bukan loop `put` per alert.                                                                                                                                                                                                  |
| High     | H7 - Finnhub response validation        | PARTIAL        | validasi ada di `stocks_repository.dart`, tetapi response shape belum disaring secara tipe dan call still bisa memicu runtime error untuk anomalous payload.                                                                                     |
| High     | H8 - Crypto chart null/ cache handling  | PASS           | `crypto_repository.dart` menambahkan try/catch decode cache dan safe parsing.                                                                                                                                                                    |
| High     | H9 - HomeWidget error handling          | PASS           | background widget update dilindungi `try/catch`.                                                                                                                                                                                                 |
| Medium   | M1 - Timer cache invalidation           | PASS           | `api_provider.dart` menggunakan `Timer` + `ref.onDispose(cancel)`.                                                                                                                                                                               |
| Medium   | M2 - Isar batch update optimasi         | PASS           | `deleteCustomCategory()` dan background sync menggunakan `putAll`/`putAllByIndex`.                                                                                                                                                               |
| Medium   | M3 - Isar @Index optimasi               | PASS           | `asset_cache`, `price_alert`, `chart_cache`, `watchlist_category` sudah memiliki indeks penting.                                                                                                                                                 |
| Medium   | M4 - parallel API call race / time lock | PASS           | `MarketSyncUseCase` dan background service sudah menerapkan time-lock validasi.                                                                                                                                                                  |

---

## Temuan Kerentanan dan Data Statis

### 1. Data Statis / Mock (Blocker)

Semua fungsi berikut masih menampilkan data non-dinamis / fallback mock:

- `lib/core/repositories/forex_repository.dart`
  - `List<List<double>> _generateDummyChart(...)`
  - `dummyChange` di `fetchForexMarkets()` menghasilkan nilai sintetis.
- `lib/core/repositories/stocks_repository.dart`
  - `List<List<double>> _generateDummyChart(...)`
  - `fetchHistoricalData()` dapat kembali ke dummy chart pada kegagalan API.
- `lib/core/repositories/crypto_repository.dart`
  - `List<List<double>> _generateStablecoinChart(...)`
  - stablecoin historis memakai data sintetis meskipun instruksi release meminta semua data dinamis.

> Status: BLOCKER. Untuk rilis produksi, semua grafik dan perubahan harga harus berasal dari API/data live yang valid, bukan fallback statis.

### 2. Kebocoran API Key / Secret Handling

- `.env` ada di root proyek dan berisi `FINNHUB_API_KEY=d802ip9r01qj3ct8qqjgd802ip9r01qj3ct8qqk0`.
- `lib/core/env/env.dart` menggunakan `envied` dengan `obfuscate: true`, dan `lib/core/env/env.g.dart` berisi key dalam bentuk array XOR.
- `FINNHUB_API_KEY` tidak di-ignore oleh `.gitignore` saat ini.

> Status: CRITICAL SECURITY ISSUE. `.env` harus segera dihapus dari repositori, ditambahkan ke `.gitignore`, dan API key harus diputar/dirotasi jika sudah pernah ter-commit.

### 3. IsarService / Database Resource Management

- `lib/core/providers/api_provider.dart` telah memperbaiki singleton untuk provider-utama.
- Namun, instansiasi `IsarService()` langsung masih ditemukan di:
  - `lib/core/providers/alert_provider.dart`
  - `lib/core/providers/exchange_rate_provider.dart`
  - `lib/core/theme/theme_provider.dart` (partial lazy init)
  - `lib/features/asset_detail/asset_detail_screen.dart`
  - `lib/shared/widgets/price_alert_bottom_sheet.dart`
  - `lib/features/markets/markets_screen.dart`
  - `lib/features/dashboard/dashboard_screen.dart`

> Status: DESIGN RISK. `IsarService` masih dibuat berulang di banyak entry point. Meskipun openDB() sudah aman, ini tetap memperlemah tujuan singleton global dan meningkatkan potensi resource waste.

### 4. Finnhub API Validation

- `lib/core/repositories/stocks_repository.dart` sudah menggunakan `timeout`, logging, dan fallback dummy chart.
- Validasi respons Finnhub belum sepenuhnya tipe-safe sebelum evaluasi `data['c'] > 0` dan `data['dp']`.

> Status: CAUTION. Perlu pengetesan payload Finnhub malformed dan penanganan `Map<String, dynamic>` secara eksplisit.

---

## Kesimpulan Status Kelayakan Rilis

**Verdik: NEEDS FIX**

Alasan utama:

1. `lib/core/repositories/` masih mengandung data dummy / fallback statis yang bertentangan dengan persyaratan data dinamis.
2. `.env` file sensitif hadir di repository tanpa perlindungan `.gitignore`.
3. `IsarService` singleton belum diterapkan secara konsisten di seluruh aplikasi; masih ada instansiasi langsung yang berpotensi resource waste.

Meskipun banyak perbaikan arsitektur telah dilakukan (timer invalidation, writeTxn try/catch, Isar indexing, background service protection, dan assetMap O(1) lookup), kondisi saat ini belum memenuhi syarat produksi untuk rilis `v1.0.1`.

---

## Rekomendasi Prioritas Perbaikan

1. Hapus `.env` dari repositori dan tambahkan ke `.gitignore`.
2. Putar/rotasi `FINNHUB_API_KEY` jika kunci sudah tercatat dalam SCM.
3. Hilangkan semua fallback chart/data statis di `lib/core/repositories/*`; gunakan API resmi atau hentikan tampilan grafik jika data tidak tersedia.
4. Jadikan `IsarService` benar-benar singleton global atau gunakan dependency injection terpusat untuk semua akses Isar.
5. Tambahkan validasi tipe eksplisit pada respons Finnhub di `stocks_repository.dart`.
6. Lakukan regression test untuk path `fetchHistoricalData()` di ketiga repository dengan respons malformed / missing field.

---

## Catatan Tambahan

- `Isar` schema sudah dioptimalkan dengan indeks penting pada `symbol`, `customCategories`, `cacheKey`, `price_alert.symbol`, `price_alert.isActive`, dan `watchlist_category.name`.
- `api_provider.dart` timer invalidation sudah diterapkan dengan cancel callback, sehingga tidak ada kebocoran `Timer` langsung.
- `background_service.dart` sudah menangani kesalahan penuh di callback Workmanager dan transaksi Isar.
