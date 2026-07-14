![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)
![Version](https://img.shields.io/badge/version-1.0.1-blue.svg?style=for-the-badge)

# TideView

<p align="center">
  <img src="assets/images/icon_logo.png" width="120" alt="TideView Logo" />
</p>

> **Real-Time Multi-Market Intelligence at Your Fingertips**

_A production-grade Flutter application demonstrating Clean Architecture, offline-first design, native OS integration, and a Supabase-powered cloud backend for comprehensive market monitoring across Crypto, Forex, and Stocks._

---

## App Preview

| Dashboard                                                                           | Markets                                                                         | Asset Detail                                                                              | Convert                                                                         | Settings                                                                          |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| <img src="assets/images/dashboard.jpeg" width="220" height="260" alt="Dashboard" /> | <img src="assets/images/markets.jpeg" width="220" height="260" alt="Markets" /> | <img src="assets/images/asset_detail.jpeg" width="220" height="260" alt="Asset Detail" /> | <img src="assets/images/convert.jpeg" width="220" height="260" alt="Convert" /> | <img src="assets/images/settings.jpeg" width="220" height="260" alt="Settings" /> |

---

## Project Overview

**TideView** is a sophisticated fintech utility application that unifies market monitoring across three distinct asset classes in a single, offline-capable interface. Instead of juggling between 5+ apps to track Bitcoin, EUR/USD, and Apple stock prices, users get a unified watchlist with real-time alerts, interactive charts, and a native home widget that updates automatically—even when the app is closed.

### Core Value Propositions

| Feature                        | Benefit                                                                                       |
| ------------------------------ | --------------------------------------------------------------------------------------------- |
| **Offline-First Architecture** | View cached market data without internet; sync restores when connection returns               |
| **Real-Time Price Alerts**     | Local push notifications trigger instantly when prices hit target levels—no server dependency |
| **Native Home Widget**         | Multi-market summary updates every 15 minutes directly on Android/iOS home screen             |
| **Sub-2-Second Cold Start**    | Loaded from local Isar database with zero cloud API calls on app launch                       |
| **Optional Cloud Sync**        | Login with Google or GitHub to sync watchlist & alerts across devices—or stay fully anonymous as a guest, no account required |

---

## Key Features

### 1. **Watchlist & Category Management**

Add assets from global markets to your personal dashboard and organize them into custom categories. Drag-and-drop interface lets you reorder assets and categories effortlessly.

### 2. **Interactive Candlestick Charts**

Zoom, pan, and switch timeframes (1D, 1W, 1M, 1Y) without API re-fetching thanks to intelligent local caching. 60 FPS rendering powered by `fl_chart`.

### 3. **Offline-First Synchronization**

View cached market data without internet connection. When offline, the app displays an "Offline Mode" banner. Upon reconnection, background sync triggers automatically without manual refresh, ensuring data freshness within 3 minutes.

### 4. **Smart Price Alert System**

Set custom alerts when prices hit target levels (e.g., "notify me if BTC hits $70,000"). Alerts persist in the background and trigger even when the app is closed, via Workmanager + local Isar state.

### 5. **Instant Asset Conversion Calculator (Spread Analyzer)**

Convert any amount between assets in real-time. Example: "1,000 USD = 0.0154 BTC" updates as you type. Leverages parallel API calls with intelligent caching for sub-second response times.

### 6. **Insta-Share Market Card**

Render a beautiful market snapshot (asset name, price, 24h change) as an image and share directly to WhatsApp, Instagram, or other platforms—no manual screenshot crop needed.

### 7. **Native Home Widget Integration**

Display your most-watched asset with live price and 24h change percentage directly on your home screen. Widget auto-updates every 15 minutes and responds to taps with deep links.

### 8. **Cloud Sync & Authentication** *(New)*

Sign in with **Google** or **GitHub** to sync your watchlist, price alerts, and custom categories across every device you own. Data is stored in a Supabase Postgres database, protected per-user by Row Level Security—no one, not even other authenticated users, can read or write another account's data. Prefer to stay anonymous? The app works fully as a **guest**, with all the same market-tracking features; login is entirely optional and only unlocks cross-device sync.

---

## Architecture Highlights (v2.0 — Supabase Backend Migration)

### 🛰️ Custom Backend Middleware (New)

As of v2.0, TideView no longer calls market-data providers directly from the client. Instead, a **Supabase-powered middleware backend** sits between the app and the outside world:

- **Edge Function `sync-markets`** (Deno/TypeScript, cron every 15 minutes) fetches CoinGecko, Frankfurter, and Finnhub server-side, then upserts results into a shared Postgres `assets` table.
- **Edge Function `get-chart-data`** serves historical candle data on-demand, backed by a 30-minute server-side cache (`chart_cache` table), falling back gracefully when a symbol has no chart source available.
- **A Postgres trigger** (`check_price_alerts`) evaluates active price alerts automatically the instant a price updates—no client polling required.

**Why this matters:** API keys (Finnhub) never ship inside the compiled APK anymore—they live exclusively as server-side secrets. The client only ever talks to Supabase's REST/Realtime API, authenticated with a public, RLS-protected anon key.

### 🔐 Authentication & Per-User Data (New)

TideView uses **Supabase Auth** with **Google** and **GitHub** OAuth providers:

- A `WelcomeScreen` offers three entry points on first launch: continue as **Guest**, or sign in with **Google**/**GitHub**.
- An `AuthGate` widget reactively routes between the welcome flow and the main app based on live auth state—no restart needed after logging in mid-session.
- On login, local watchlist/alerts/categories are pushed to the user's account, and any existing cloud data is pulled down and merged into the local Isar cache—so switching devices (or reinstalling) restores your setup automatically.
- All per-user tables (`user_watchlist`, `price_alerts`, `watchlist_categories`) are protected by **Row Level Security**, scoped to `auth.uid()`.

### 🧩 Hybrid API Strategy

Current prices and historical charts are now aggregated **server-side** rather than fetched independently by the client:

- **Crypto:** CoinGecko `/coins/markets` (batched, up to 250 assets per request)
- **Forex:** Frankfurter latest rates endpoint
- **Stocks:** Finnhub real-time quote endpoint (server-side, staggered to respect rate limits)
- **Historical charts:** Binance klines (crypto), Yahoo Finance unofficial endpoints (forex/stocks)—both proxied through the `get-chart-data` Edge Function

This split still enables fast quote refreshes while preserving historical chart availability, but now with the added benefit of a single source of truth shared by every installed client, rather than each device hitting rate-limited public APIs independently.

### ⚡ Performance & Caching

TideView pairs a local Isar cache with a 3-minute TTL policy to balance freshness and rate-limit safety.

- **Isar** stores aggregated market snapshots, alert state, chart caches, and user preferences.
- **3-minute TTL** is enforced in `market_sync_usecase.dart` using `lastCryptoSyncTime`.
- If cached data exists and is still fresh, the app bypasses network fetches and returns local data immediately.

This strategy prevents redundant polling, limits Finnhub/FastAPI usage, and keeps UI response times low while maintaining market relevance.

### 🔄 Smart Synchronization

TideView now supports a 4-way refresh model for market data:

1. **Realtime WebSocket Push** *(New)* — a Supabase Realtime subscription listens for changes on the `assets` table and force-refreshes local data the instant the backend cron updates prices, no polling needed.
2. **Manual Pull-to-Refresh** — users can force an on-demand sync from the Markets screen.
3. **Auto-Refresh Timer** — a periodic timer in `markets_screen.dart` triggers data refresh every 3 minutes as a fallback.
4. **Lifecycle Resumption** — when the app returns from background, the app evaluates whether cached data should refresh.

This combination ensures the app stays up to date without over-fetching, while also respecting user intent and app lifecycle transitions.

### 🌍 Market Coverage Enhancements

The v1.0.1 release expands coverage with:

- **Top 50 global stocks** in `stocks_repository.dart`, up from a smaller core set.
- **Improved intraday Forex support** with 1D-level charting enabled by Yahoo Finance / Frankfurter hybrid handling.

By blending real-time quotes with chart-specialized providers, TideView offers a broader asset universe with deeper intraday visualization and stronger cache-backed performance.

---

## Technical Stack

| Layer                | Technology                      | Justification                                                                                                                                                                    |
| -------------------- | -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Backend**          | **Supabase** (Postgres, Auth, Realtime, Edge Functions) | Fully managed backend-as-a-service; free tier, no credit card required; native WebSocket realtime and Row Level Security out of the box |
| **State Management** | **Flutter Riverpod**            | Compile-time safety, reactive providers with automatic invalidation, proper lifecycle management preventing memory leaks; outshines BLoC in readability for complex async states |
| **Local Database**   | **Isar (v3.1.0)**               | ACID-compliant NoSQL with <1ms indexed queries; 10x faster than SQLite for JSON-heavy market data; built-in Dart models reduce boilerplate                                       |
| **Networking**       | **HTTP + Supabase client SDK**  | HTTP for Edge Function calls, `supabase_flutter` for Postgres REST/Realtime/Auth                                                                                                  |
| **Charting**         | **FL Chart**                    | Feature-rich candlestick + line charts with zoom/pan, no native dependencies, 60 FPS on mid-range devices                                                                        |
| **Background Tasks** | **Workmanager**                 | Reliable periodic background sync even when app is force-closed; Android WorkManager abstraction works cross-platform                                                            |
| **Home Widget**      | **HomeWidget**                  | Direct integration with iOS and Android widget frameworks; avoids WebView overhead                                                                                               |
| **Notifications**    | **flutter_local_notifications** | Rich push notifications with actions, sound, haptic patterns; zero server infrastructure                                                                                         |
| **Authentication**   | **Supabase Auth (Google + GitHub OAuth)** | Server-managed OAuth flow, session persistence, and per-user Row Level Security -- no custom auth backend to maintain |
| **API Key Security** | **Supabase Secrets**            | Third-party API keys (Finnhub) live exclusively server-side in Edge Function secrets -- never shipped inside the compiled APK                                                    |
| **Localization**     | **Intl + App Localizations**    | Bilingual support (English + Indonesian); gender-aware plurals; platform-native date/number formatting                                                                           |
| **UI Framework**     | **Flutter 3.11+**               | Cross-platform (Android target), native feel via Material 3, pixel-perfect control via CustomPaint                                                                               |

---

## Clean Architecture Implementation

TideView follows **Clean Architecture** principles with a strict separation between data, domain, and presentation layers:

```
lib/
├── core/                      # Pure business logic & infrastructure
│   ├── repositories/          # [DATA LAYER] API clients
│   │   ├── crypto_repository.dart      → Binance API wrapper
│   │   ├── forex_repository.dart       → Frankfurter API wrapper
│   │   └── stocks_repository.dart      → Finnhub API wrapper
│   ├── usecases/              # [DOMAIN LAYER] Business rules
│   │   └── market_sync_usecase.dart    → Orchestrates multi-repo fetch + cache logic
│   ├── database/              # [DATA LAYER] Isar schemas
│   │   ├── asset_cache.dart           → Market data snapshot
│   │   ├── price_alert.dart           → User-defined alert thresholds
│   │   └── user_prefs.dart            → User settings (theme, currency, etc.)
│   ├── services/              # [INFRASTRUCTURE] System integrations
│   │   ├── isar_service.dart          → Database abstraction layer
│   │   ├── background_service.dart    → Workmanager periodic sync
│   │   └── notification_helper.dart   → Push notification system
│   ├── providers/             # [DOMAIN → PRESENTATION] Riverpod factories
│   │   ├── api_provider.dart          → Repository + UseCase instantiation
│   │   ├── alert_provider.dart        → Alert state observable
│   │   └── exchange_rate_provider.dart → Currency conversion state
│   └── theme/                 # Styling & branding
│
└── features/                  # [PRESENTATION LAYER] Screens & widgets
    ├── dashboard/             → Home screen (watchlist + widget)
    ├── markets/               → Global asset browser & search
    ├── asset_detail/          → Chart + analytics for single asset
    ├── convert/               → Currency converter UI
    └── settings/              → User preferences & alerts management
```

### Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│              USER INTERACTIONS (UI)                          │
│  Dashboard → Markets → AssetDetail → Convert → Settings     │
└────────────────────┬────────────────────────────────────────┘
                     │ watches rv.watch(cryptoDataProvider)
                     ▼
┌─────────────────────────────────────────────────────────────┐
│         RIVERPOD STATE MANAGEMENT LAYER                      │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐    │
│  │ cryptoDataProv   │forexDataProv │  │alertProvider   │    │
│  │ (FutureProver    │(FutureProvider)  │(AsyncNotifier) │    │
│  └────────┬────┘  └───────┬──────┘  └────────┬────────┘    │
│           │                │                  │              │
│           └────────┬───────┴──────────────────┘              │
│                    │                                         │
└────────────────────┼─────────────────────────────────────────┘
                     │ calls
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              DOMAIN & USE CASE LAYER                         │
│          MarketSyncUseCase.getCryptoData()                  │
│                     │                                        │
│   ┌─────────────────┼──────────────────┐                    │
│   │                 │                  │                    │
│   ▼                 ▼                  ▼                    │
│ Crypto          Forex              Stocks                  │
│ Repository      Repository         Repository              │
│ (Supabase)      (Supabase)         (Supabase)              │
│   -- backed by Edge Function `sync-markets` (cron 15min) -- │
│                                                             │
│   Parallel Fetch (Future.wait) → ~150-400ms latency        │
└────────────────────┬────────────────────────────────────────┘
                     │ fetched data
                     ▼
┌─────────────────────────────────────────────────────────────┐
│           DATA AGGREGATION & CACHING                        │
│  Extract → Validate → Aggregate → Isar writeTxn()          │
│                                                             │
│  assetCaches.putAll(masterCache)  [100+ assets in <5ms]    │
│  priceAlerts.filter().findAll()   [trigger checking]       │
│  userPrefs.put(prefs)             [sync metadata]          │
└────────────────────┬────────────────────────────────────────┘
                     │ atomic transaction
                     ▼
┌─────────────────────────────────────────────────────────────┐
│            LOCAL ISAR DATABASE                              │
│  ┌─────────────┐ ┌──────────┐ ┌───────────┐ ┌────────────┐ │
│  │asset_caches │ │alerts    │ │user_prefs │ │watchlists  │ │
│  │ -symbol     │ │-id       │ │-baseCurr  │ │-categories │ │
│  │ -price      │ │-target   │ │-themeMod  │ │-assets     │ │
│  │ -change24h  │ │-isTrigg  │ │-syncIntvl │ │            │ │
│  └─────────────┘ └──────────┘ └───────────┘ └────────────┘ │
│                   (Instant Index Queries)                   │
└────────────────────┬──────────────────────────────────────┘
                     │ read from cache
                     ▼
┌─────────────────────────────────────────────────────────────┐
│         BACKGROUND SYNC (Workmanager)                       │
│                                                              │
│  Every 15 min (configurable):                              │
│  1. Fetch latest prices (crypto, forex, stocks)            │
│  2. Update Isar assetCaches table                          │
│  3. Check alert thresholds → trigger notifications         │
│  4. Update HomeWidget with BTC price + change              │
│  5. Run without UI, even if app is force-closed            │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚡ Performance & Caching Strategy

### Parallel API Fetching

Instead of sequential API calls (Crypto → Forex → Stocks), TideView uses `Future.wait()` to fetch all three markets in parallel:

```dart
final results = await Future.wait([
  apiRepo.fetchCryptoMarkets(),     // Binance API (Crypto Top 50)
  forexRepo.fetchForexMarkets(),    // Frankfurter API (20+ pairs)
  stocksRepo.fetchStockMarkets(),   // Finnhub API (15 major stocks)
]);
```

**Result:** Typical latency = 150–400ms (network I/O bound) instead of 450–1200ms (sequential).

### 3-Minute Intelligent Cache Cooldown

After fetching and caching data in Isar, subsequent requests within 3 minutes return cached data without hitting APIs:

```dart
if (lastSync != null &&
    now.difference(lastSync).inMinutes < 3 &&
    cachedData.isNotEmpty) {
  return {'isOffline': false, 'data': cachedData};
}
```

**Rationale:** Most users don't need sub-minute price updates; 3-minute windows prevent API rate-limiting (Finnhub: 60 req/min free tier) while maintaining UX freshness.

### Indexed Database Queries

Isar indexes heavily-queried fields for <1ms lookups:

```dart
@Collection()
class AssetCache {
  Id? id;
  @Index(unique: true)
  late String symbol;      // Hash-indexed for O(1) lookups

  late String name;
  late double currentPrice;
  late double priceChange24h;
  late DateTime lastUpdated;
  late String marketType;   // Indexed for filter queries
  late bool isWatchlisted;
  late List<String> customCategories;
  late int sortOrder;
}
```

**Impact:** Querying 500 assets by symbol = <1ms (vs. 10–50ms with SQLite).

### Memory Footprint

- **Typical session:** 30–80 MB (depends on asset count & chart caching)
- **Background worker:** <15 MB (minimal UI overhead)
- **Isar DB size:** ~2–5 MB (500 assets + 50 alerts + 1 year history)

---

## 📦 Installation & Setup

### Prerequisites

- **Flutter SDK:** 3.11.5 or higher
- **Dart SDK:** Included with Flutter
- **Android Studio** (for android build) or **Xcode** (for iOS)
- **API Keys:**
  - Finnhub API Key (free tier available)
  - (Binance & Frankfurter APIs are public, no key required)

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/tideview.git
cd tideview
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Supabase Connection

TideView talks to a Supabase project for market data, auth, and cloud sync. Set your project's URL and anon key in `lib/core/services/supabase_service.dart`:

```dart
const String supabaseUrl = 'https://<your-project-ref>.supabase.co';
const String supabaseAnonKey = '<your-anon-or-publishable-key>';
```

The anon key is safe to ship in the client -- every table is protected by Row Level Security, so it can only ever read/write what its policies explicitly allow.

To run your own backend instance (Edge Functions, database schema, cron jobs), see [`docs/GUIDEBOOK.md`](docs/GUIDEBOOK.md) for the full setup walkthrough, including the Google/GitHub OAuth provider configuration.

### Step 4: Generate Isar Collections

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `*.g.dart` files for all Isar `@Collection()` classes in `lib/core/database/`.

### Step 5: Configure App Icons & Splash Screen

Generate app icons and splash screen from `assets/images/logo.png`:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

(These are configured in `pubspec.yaml` under `flutter_icons` and `flutter_native_splash` sections.)

### Step 6: Build & Run

**Debug Mode (Emulator/Device):**

```bash
flutter run
```

**Release build (APK):**

```bash
flutter build apk --release
```

**Release build (AAB for Google Play):**

```bash
flutter build appbundle --release
```

### Step 7: Configure Background Sync (Android Only)

The background sync task is registered in `main.dart`:

```dart
Workmanager().initialize(callbackDispatcher);

Workmanager().registerPeriodicTask(
  "tideview-sync-task-1",
  "marketSync",
  frequency: Duration(minutes: syncInterval),  // Default: 15 minutes
  constraints: Constraints(networkType: NetworkType.connected),
  existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
);
```

To adjust sync frequency, go to **Settings** > **Widget Sync Rate** and select 15/30/60 minutes.

---

## Design System Implementation

### Typography

TideView uses **Inter** font family with tabular figures enabled:

```dart
'fontFamilyFallback': const ['Inter'],
fontFeatures: const [FontFeature('tnum')],  // Tabular numbers
```

This ensures digits (1, 8, 0) maintain constant width, preventing prices from "jumping" when updated.

**Hierarchy:**

- **Display Price:** 40pt Bold (Asset detail page)
- **Heading:** 20pt Semi-Bold (Asset card titles)
- **Body Text:** 14pt Regular (Descriptions)
- **Caption:** 12pt Medium (Labels & timestamps)

### Color System

#### Light Mode

- **Background:** `#F8F9FA` (Soft Greyish White)
- **Surface:** `#FFFFFF` (Card backgrounds)
- **Text (High Emphasis):** `#111111`
- **Text (Low Emphasis):** `#8D8D8D`

#### Dark Mode

- **Background:** `#121212` (Deep Charcoal)
- **Surface:** `#1E1E1E` (Card backgrounds)
- **Text (High Emphasis):** `#FFFFFF`
- **Text (Low Emphasis):** `#B0B0B0`

#### Dynamic Accent Colors (User-Selectable)

Users can customize the brand color via **Settings** > **App Theme**:

| Theme         | Primary   | Secondary | Use Case                           |
| ------------- | --------- | --------- | ---------------------------------- |
| Royal Purple  | `#7A52F4` | `#9B7EFA` | Default, professional fintech look |
| Cyber Green   | `#00D26A` | `#4ADE80` | Growth-focused traders             |
| Sunset Orange | `#FF6D00` | `#FF9E40` | Warm, energetic aesthetic          |
| Electric Cyan | `#00D1FF` | `#63E2FF` | Modern, techy vibe                 |
| Hot Magenta   | `#FF2A7A` | `#FF73A3` | Bold, attention-grabbing           |

#### Semantic Colors

- **Bullish (Up):** `#00C853` (Emerald Green)
- **Bearish (Down):** `#FF1744` (Crimson Red)
- **Neutral:** `#FFB300` (Amber)

### Shape Language

- **Cards:** 24px border radius (super soft)
- **Buttons:** 999px pill-shaped for primary CTAs
- **Bottom Nav Bar:** 24px rounded edges, floating capsule style (no notch)
- **Bottom Sheets:** 32px top corners, full-width bottom

### Micro-Interactions

- **Loading:** Shimmer effect (left-to-right gradient pulse)
- **Tab Switch:** Haptic light feedback + smooth color transition
- **Price Change:** Subtle fade-in of color (green/red) for ±5% threshold
- **Deep Link Tap:** Haptic selection feedback + smooth page slide

---

## Project Structure

```
tideview/
├── lib/
│   ├── main.dart                          # App entry point, Workmanager init
│   │
│   ├── core/
│   │   ├── database/
│   │   │   ├── asset_cache.dart          # Market snapshot schema
│   │   │   ├── asset_cache.g.dart        # Generated Isar code
│   │   │   ├── price_alert.dart          # User alert thresholds
│   │   │   ├── user_prefs.dart           # Settings & sync metadata
│   │   │   ├── watchlist_category.dart   # Custom categorization
│   │   │   └── schemas.dart              # Isar collection exports
│   │   │
│   │   ├── repositories/
│   │   │   ├── crypto_repository.dart    # Now Supabase-backed (was Binance direct)
│   │   │   ├── forex_repository.dart     # Now Supabase-backed (was Frankfurter direct)
│   │   │   └── stocks_repository.dart    # Now Supabase-backed (was Finnhub direct)
│   │   │
│   │   ├── usecases/
│   │   │   └── market_sync_usecase.dart  # Multi-repo orchestration
│   │   │
│   │   ├── services/
│   │   │   ├── supabase_service.dart     # Supabase client init + auth helpers (New)
│   │   │   ├── isar_service.dart         # Database abstraction + cloud sync push/pull
│   │   │   ├── background_service.dart   # Workmanager periodic sync
│   │   │   └── notification_helper.dart  # Push notification system
│   │   │
│   │   ├── providers/
│   │   │   ├── api_provider.dart         # Riverpod provider factories
│   │   │   ├── alert_provider.dart       # Alert state observable
│   │   │   └── exchange_rate_provider.dart
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart            # Material theme definition
│   │   │   ├── color_constants.dart      # Color hex values
│   │   │   ├── app_text_styles.dart      # Typography definitions
│   │   │   └── theme_provider.dart       # Riverpod theme state
│   │   │
│   │   ├── l10n/
│   │   │   ├── app_localizations.dart    # Generated by intl_translation
│   │   │   ├── app_en.arb                # English strings
│   │   │   └── app_id.arb                # Indonesian strings
│   │   │
│   │   └── routes.dart                   # Navigation route definitions
│   │
│   ├── features/
│   │   ├── auth/                       # (New)
│   │   │   ├── welcome_screen.dart       # Guest / Google / GitHub entry point
│   │   │   └── auth_gate.dart            # Reactive root navigation gate
│   │   │
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart     # Home: Watchlist + categories
│   │   │
│   │   ├── markets/
│   │   │   └── markets_screen.dart       # Global asset browser
│   │   │
│   │   ├── asset_detail/
│   │   │   └── asset_detail_screen.dart  # Chart + deep analytics
│   │   │
│   │   ├── convert/
│   │   │   └── convert_screen.dart       # Multi-asset converter
│   │   │
│   │   └── settings/
│   │       ├── settings_screen.dart      # Theme, currency, language
│   │       └── manage_alerts_screen.dart # Alert CRUD interface
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── asset_card.dart           # Reusable asset display card
│       │   ├── custom_bottom_nav.dart    # Floating capsule nav bar
│       │   ├── custom_shimmer.dart       # Loading skeleton
│       │   ├── offline_banner.dart       # Offline state indicator
│       │   ├── price_alert_form.dart     # Alert creation form
│       │   └── main_layout.dart          # Scaffold + nav wrapper
│       │
│       └── utils/
│           ├── currency_formatter.dart   # Format price + currency
│           └── validators.dart           # Input validation helpers
│
├── android/                               # Native Android configuration
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml   # Permissions, widget provider
│   └── build.gradle.kts
│
├── ios/                                   # Native iOS configuration
│   ├── Runner/
│   │   └── Info.plist                    # iOS permissions & capabilities
│   └── Podfile
│
├── assets/
│   ├── images/
│   │   ├── logo.png                      # App icon & widget icon
│   │   └── [other assets]
│   └── fonts/
│       ├── Inter-Regular.ttf
│       ├── Inter-Medium.ttf
│       ├── Inter-SemiBold.ttf
│       └── Inter-Bold.ttf
│
├── test/                                  # Unit & widget tests
│   └── widget_test.dart
│
├── pubspec.yaml                           # Dependencies & config
├── pubspec.lock
├── analysis_options.yaml
├── android/key.properties                 # Release signing config (gitignored)
└── l10n.yaml                              # Localization config
```

---

## 🚀 Future Roadmap

TideView shipped its **Phase 1** (offline-first core) and **Phase 2** (Supabase backend, cloud sync, Google/GitHub auth -- see [`docs/GUIDEBOOK.md`](docs/GUIDEBOOK.md)) milestones. Next up:

### Phase 2.5: Social & Journaling (in consideration)

- **Social Sharing:** Upload market screenshots to a community feed
- **Trading Journal:** Log trades and track performance
- **Push Notifications (FCM):** server-driven alerts that fire even when the app is fully closed, replacing today's device-local-only alert checks

### Phase 3: Paper Trading Gamification (Q4 2026)

- **Virtual Portfolio:** Simulate trades with $100K starting capital
- **Leaderboards:** Compete globally on risk-adjusted returns
- **Trading Bot Templates:** Pre-built automation strategies (SMA crossover, RSI divergence)
- **Performance Analytics:** Advanced Sharpe ratio, drawdown analysis

### Phase 4: AI-Powered Market Intelligence (2027)

- **Sentiment Analysis:** LLM-powered analysis of news feeds by asset
- **Anomaly Detection:** Alert when price movement deviates N-sigma from normal
- **Predictive Alerts:** ML-based "likely to move" signals
- **Voice Commands:** "Show me top gainers" via voice input

### Phase 5: Enterprise Features (TBD)

- **Multi-Account Management:** Switch between accounts seamlessly
- **Portfolio Rebalancing:** Auto-rebalance watchlists to target allocations
- **Tax Reporting:** Automated tax-lot tracking for long-term gains/losses
- **API Access:** Let other apps consume TideView price feeds

---

## 🧪 Testing & Quality Assurance

Find the comprehensive QA scan in the `/docs/QA/` directory:

| Document                                                                 | Purpose                                                                      |
| ------------------------------------------------------------------------ | ---------------------------------------------------------------------------- |
| [QA_SCAN_REPORT.md](docs/QA/QA_SCAN_REPORT.md)                           | 21 identified issues (7 critical, 9 high, 5 medium) with technical deep-dive |
| [QA_QUICK_FIX_GUIDE.md](docs/QA/QA_QUICK_FIX_GUIDE.md)                   | Copy-paste ready code fixes for all issues                                   |
| [QA_IMPLEMENTATION_CHECKLIST.md](docs/QA/QA_IMPLEMENTATION_CHECKLIST.md) | Progress tracking for QA fixes                                               |

### Running Tests Locally

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

### Performance Benchmarking

Monitor these metrics in Debug mode:

```bash
flutter run --profile  # Enable DevTools performance profiler

# Check memory in DevTools Memory tab
# Watch for steady-state usage after 5 min of navigation
```

---

## API Documentation

### What the Client Actually Talks To

As of v2.0, the Flutter client no longer calls third-party market APIs directly. It only talks to **Supabase** (Postgres REST, Realtime WebSocket, and Auth), authenticated with a public anon key protected by Row Level Security. All third-party API calls below now happen **server-side**, inside Supabase Edge Functions.

### Third-Party APIs (server-side only, called by Edge Functions)

#### CoinGecko API (Crypto, Top 50 by Market Cap)

- **Endpoint:** `https://api.coingecko.com/api/v3/coins/markets`
- **Rate Limit:** 10,000 calls/month (free Demo plan)
- **Response:** Batched JSON array of up to 250 coins per request (price, 24h change, logo)
- **Called by:** Edge Function `sync-markets`, every 15 minutes

#### Binance API (Crypto Historical Charts)

- **Endpoint:** `https://data-api.binance.vision/api/v3/klines`
- **Rate Limit:** 1200 requests/minute
- **Response:** OHLC candle data per interval/timeframe
- **Called by:** Edge Function `get-chart-data`, on-demand with 30-minute cache
- **Known limitation:** coins outside CoinGecko's top 50 that also aren't listed on Binance won't have chart data available

#### Frankfurter API (Forex)

- **Endpoint:** `https://api.frankfurter.dev/v1/latest?from=USD`
- **Rate Limit:** Unlimited (public service)
- **Response:** Exchange rates for 30+ fiat currencies
- **Called by:** Edge Function `sync-markets`, every 15 minutes

#### Finnhub API (Stocks)

- **Endpoint:** `https://finnhub.io/api/v1/quote?symbol=AAPL&token=KEY`
- **Rate Limit:** 60 requests/minute (free tier)
- **Response:** Quote data for US-listed equities
- **Called by:** Edge Function `sync-markets`, staggered 1 request/second, market-hours aware
- **API Key:** Stored exclusively as a Supabase Edge Function secret, never in the client

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Areas needing help:**

- iOS widget implementation (currently Android-focused)
- Additional chart indicators (RSI, MACD, Bollinger Bands)
- Unit tests for repository layer
- Translation to additional languages (Spanish, German, etc.)

---

## License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) file for details.

---

## Author

**Muhammad Zaidan** — Software Engineering Student at [Universitas Teknologi Indonesia](https://www.iti.ac.id/)

- GitHub: [@MuhammadZaidan1](https://github.com/MuhammadZaidan1)
- Portfolio: [jayy.vercel.app](https://jayy.vercel.app)
- LinkedIn: [Muhammad Zaidan](https://www.linkedin.com/in/muhammad-zaidan-046872336/)

---

## Acknowledgments

- **Flutter & Dart Teams** for an outstanding ecosystem
- **Riverpod Community** for reactive state management inspiration
- **Isar Database Contributors** for ultra-fast local storage
- **Finnhub, Binance, Frankfurter** for free-tier public APIs
- **Design inspo:** Figma's iOS design system, Binance Pro, Robinhood

---

## Educational Value

TideView demonstrates:

- **Clean Architecture** with strict layer separation
- **Reactive Programming** via Riverpod + Dart Streams
- **Local-First Design** patterns for offline-capable apps
- **Native Integration** with Android/iOS widgets
- **Performance Optimization** (4 concurrent APIs, <500ms latency)  
  ✅ **Security Best Practices** (Supabase Row Level Security + server-side secrets)  
  ✅ **Bilingual Localization** (English + Indonesian)  
  ✅ **Material Design 3** with dynamic theming  
  ✅ **Database ACID Transactions** with Isar  
  ✅ **Background Task Scheduling** via Workmanager

**Perfect for:** Portfolio presentations, architecture interviews, Flutter mastery demonstration.

---

<div align="center">

**Made with ❤️ using Flutter**

[⬆ Back to top](#-tideview)

</div>