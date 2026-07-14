# PRODUCT REQUIREMENTS DOCUMENT
## TIDEVIEW MOBILE APPS

---

## 1. PRODUCT SUMMARY
Aplikasi mobile utility pemantau pasar lintas sektor (Kripto, Valas, dan Saham) yang fokus pada kecepatan akses via Home Widget, kapabilitas offline-first, dan pemanfaatan fitur native OS Android.

**Primary goal:**
* Menyediakan akses informasi harga aset tercepat tanpa harus membuka aplikasi (via Widget).
* Mendemonstrasikan implementasi Clean Architecture dan Native Android Integration menggunakan Flutter.

---

## 2. PROJECT & BUSINESS CONTEXT
**Project Context:**
* Tugas Besar Mata Kuliah Pemrograman Mobile (Target: Lulus dengan nilai maksimal/A di Institut Teknologi Indonesia).
* Portofolio Software Engineering dan Project Management.

**Core Offer:**
* Pemantauan harga 3 market berbeda dalam 1 layar.
* Kalkulator konversi lintas aset (Spread/Premium Analyzer).
* Berbagi rangkuman aset instan (Insta-Share).

**Value Proposition:**
* Tidak butuh koneksi internet 100% (offline cache).
* Sistem alarm lokal tanpa bergantung pada server backend.
* Ringan, privasi terjaga (tidak ada login/tracking server).

---

## 3. TARGET USER
**Demographic:**
* Umur: 18 - 35 tahun (Melek finansial/teknologi).
* Profesi: Mahasiswa IT, Trader ritel, Karyawan.

**Awareness Level:**
* Butuh alat pantau yang tidak memakan RAM tinggi.
* Dosen penilai yang fokus pada struktur arsitektur kode dan implementasi UI/UX.

---

## 4. USER PAIN POINTS
* Harus berpindah-pindah 3 aplikasi berat (Binance, RTI, Browser) hanya untuk mengecek harga aset yang berbeda.
* Aplikasi finance layar putih/error saat kehilangan sinyal (misal di basement/MRT).
* Kesulitan menghitung manual nilai tukar kripto ke Rupiah.
* Ribet screenshot dan crop grafik harga untuk di-share ke WhatsApp atau Instagram Story.

---

## 5. PRIMARY USER FLOW
* **Main Flow 1 (Fast Monitoring):** Layar Home HP → Lihat Widget TideView → Data Refresh Otomatis.
* **Main Flow 2 (Market Exploration & Watchlist):** Buka Aplikasi → Pindah ke tab Markets → Cari aset (Search) atau lihat Top Gainer → Klik "Add to Watchlist" → Pilih/Buat Kategori → Aset muncul di Dashboard.
* **Main Flow 3 (Asset Analysis & Conversion):** Buka Aplikasi → Klik Aset (misal: BTC) di Dashboard → Halaman Detail (Lihat Candlestick) → Kembali (Back) ke menu utama → Pindah ke tab Convert di Bottom Nav → Masukkan angka IDR → Lihat hasil konversi BTC → Klik "Share" → Redirect ke IG Story.

---

## 6. APP NAVIGATION STRUCTURE

**Primary Navigation (Bottom Navigation Bar):**
Desain navigasi utama menggunakan bentuk kapsul melayang (pill-shaped) simetris tanpa FAB, berisi 4 menu sejajar:
* **Dashboard:** Halaman utama berisi Watchlist pribadi yang dikelompokkan berdasarkan kategori (customizable).
* **Markets:** Halaman eksplorasi database global, pencarian aset (Search), dan Top Movers.
* **Convert:** Halaman fungsional khusus kalkulator silang (Spread Analyzer).
* **Settings:** Pengaturan Aplikasi (App Theme Mode, Custom Color Accent [5 pilihan warna], Language/Bahasa [EN, ID], Base Currency, Widget Sync Rate, Local Alarms, Storage/Clear Cache).

**Secondary Navigation (Stack / Deep Pages):**
**Asset Detail Page (/detail/[asset_id]):** Halaman spesifik yang terbuka saat kartu aset diklik. Berisi:
* Header Harga & Persentase real-time.
* Interactive Candlestick Chart (Bisa di-zoom/pan).
* Timeframe Customizer (Tombol filter grafik: 1D, 1W, 1M, 1Y).
* Statistik Fundamental (High/Low 24h).
* CTA Button: "Insta-Share Card".

**Overlays & Modals (Pop-up Interactions):**
* **Search Overlay:** Tampilan layar penuh/setengah layar yang menutupi halaman Markets saat kotak pencarian diklik, memuat input text dan hasil pencarian global (debounced).
* **Edit Layout Mode / Bottom Sheet:** Mode interaktif di Dashboard (diaktifkan via tombol Edit atau Long Press) yang memunculkan UI khusus untuk drag-and-drop urutan kategori market.
* **Add/Edit Alarm Modal:** Pop-up form untuk mengatur kondisi alarm (Pilih Aset, Kondisi Harga, dan Target Angka) yang dipanggil dari halaman Settings.
* **Share Preview / Rendering Toast:** UI loading singkat atau pratinjau gambar (Insta-Share) saat aplikasi sedang merender grafik menjadi `dart:ui.Image` sebelum memanggil Android Share Intent.
* **Offline State Banner:** Notifikasi sticky (pita peringatan di bagian atas UI) yang otomatis muncul di Dashboard jika perangkat kehilangan koneksi internet.

---

## 7. NATIVE CAPABILITIES INTEGRATION
**Core Native Features:**
* **Mixed Home Widget:** UI dinamis di homescreen Android (Kripto, Saham, Valas) di-update via WorkManager.
* **Cross-Market Local Alarm:** Trigger suara/notifikasi dari background OS Android jika logic harga terpenuhi.
* **Share Intent (Insta-Share):** Me-lempar data image byte langsung ke aplikasi pihak ketiga (WA/IG).
* **Haptic Feedback:** Getaran taktil saat ganti timeframe grafik atau drag-and-drop widget.

---

## 8. LOCAL STORAGE & STATE MANAGEMENT
Sistem ini murni client-side, tidak menggunakan BaaS (Supabase/Firebase).
* **Data Source:** Local DB (Isar atau SQLite) untuk Offline-First Sync.
* **State Management:** Riverpod atau BLoC untuk sinkronisasi UI dan logic.

**Data Cache Structure:**
* `asset_id`: ID Aset.
* `last_price`: Harga terakhir di-fetch.
* `last_updated`: Timestamp waktu data ditarik.
* `historical_data`: Array data candlestick untuk offline chart.
* `user_preferences`: Skema untuk menyimpan konfigurasi lokal (Theme, Base Currency, Sync Rate, dan list Local Alarms).
* `watchlist_data`: Skema tabel untuk menyimpan daftar ID aset favorit pengguna beserta label kategorinya.

---

## 9. FUNCTIONAL REQUIREMENTS
**Core Features:**
* **Watchlist & Category Management:** Pengguna dapat menambahkan aset dari global market ke personal dashboard dan mengelompokkannya ke dalam tab kategori kustom.
* **Offline-First Synchronization:** Menampilkan data cache lokal (DB) jika tidak ada koneksi internet dengan label "Offline Mode".
* **Drag-and-Drop Modular Dashboard:** Pengguna dapat menyusun ulang urutan kotak kategori pasar di halaman utama.
* **Debounced Search:** Pencarian global di halaman Markets dengan jeda 500ms untuk mencegah pemblokiran API Rate Limit.
* **Spread Analyzer (Convert):** Kalkulator dinamis membandingkan harga aset A dengan aset B secara real-time.
* **Insta-Share Market Card:** Konversi UI widget spesifik menjadi `dart:ui.Image` untuk di-share tanpa screenshot manual layar penuh.
* **Configurable Settings:** Sistem menyediakan kendali personalisasi antarmuka (Light/Dark Mode, serta 5 pilihan Dynamic Color Theme), lokalisasi bahasa (Bilingual: English & Indonesian), patokan mata uang (Base Currency), interval pembaruan Widget, dan manajemen memori lokal (Clear Cache).

---

## 10. NON FUNCTIONAL REQUIREMENTS
**Performance:**
* Layar Candlestick dan daftar aset harus render stabil di 60 FPS.
* Proses background Worker (untuk Widget & Alarm) maksimal menggunakan RAM < 50MB.
* Cold Start aplikasi hingga memuat antarmuka dari Local Storage < 2 detik.

**Reliability & Usability:**
* Graceful error handling: Tidak ada Force Close saat API timeout atau struktur JSON berubah.
* Mendukung mode potret (portrait) pada rasio layar standar.

---

## 11. API & DATA SOURCES
Hanya Read-Only Data (Public API):
* **Crypto:** CoinGecko API (Endpoints: `/simple/price`, `/coins/{id}/ohlc`).
* **Forex:** Frankfurter API (Endpoint: `/latest`).
* **Stocks:** Finnhub API (Endpoint: `/quote`).

---

## 12. DESIGN DIRECTION
* **Design Style:** Modern Soft FinTech (Dynamic Accent, Clean Overlap, Light/Dark Adaptive).
* **Tone:** Profesional, Cepat, Akurat, namun Ramah (tidak mengintimidasi) dan Premium.

**UI Elements:**
* **Background Color:** Adaptive (Soft Greyish White `#F8F9FA` untuk Light Mode, Deep Charcoal `#121212` untuk Dark Mode).
* **Brand/Accent Color:** Dynamic Accent Color dengan 5 pilihan tema [...]. Warna yang dipilih pengguna akan menjadi identitas utama untuk header, tombol CTA, dan indikator tab aktif di Floating Capsule Nav Bar (menghapus referensi ke FAB).
* **Semantic Color Coding:** Emerald Green (Bullish/Naik) dan Crimson Red (Bearish/Turun).
* **Typography:** Kunci di font Inter karena memiliki fitur Tabular Numbers agar deretan harga aset sejajar sempurna secara vertikal.
* **Shape Language:** Super soft rounded corners (radius besar 24px-32px) dengan teknik overlapping layout (kartu menumpuk di atas header) untuk memberikan ilusi kedalaman (depth).
* **Micro-interactions:** Shimmer effect untuk loading state, Haptic feedback pada navigasi, dan Bottom Navigation Bar bergaya Floating Capsule simetris tanpa notch untuk mencegah layout overflow.

---

## 13. TECHNICAL APPROACH
* **Frontend:** Flutter SDK (Dart).
* **Architecture:** Clean Architecture (pemisahan Data Layer, Domain Layer, dan Presentation Layer).
* **Local DB:** Isar Database.
* **Networking:** `dio` atau `http` package.
* **Charting:** `fl_chart` atau `candlesticks` package.
* **Background Task:** `workmanager` package.

---

## 14. SUCCESS METRICS
* Aplikasi berhasil berjalan di perangkat fisik tanpa error (APK).
* Berhasil menampilkan data silang (Kripto, Saham, Valas) di Home Widget.
* Aplikasi tetap menampilkan UI Chart dan harga saat fitur WiFi/Data Seluler dimatikan.
* Proses konversi IDR ke Kripto berjalan instan.

---

## 15. LIMITATIONS
* Sistem tidak memiliki backend/cloud database, sehingga tidak ada sinkronisasi antar perangkat.
* Data saham real-time sangat bergantung pada batas hit free tier Finnhub API.
* Tidak ada fitur eksekusi trading riil (hanya dummy/simulation).

---

## 16. FUTURE ROADMAP
* **Phase 2:** Integrasi sistem akun (Supabase Auth) untuk Cloud Sync Watchlist.
* **Phase 3:** Paper Trading Gamification (Simulasi modal virtual).
* **Phase 4:** Integrasi LLM API untuk Market Sentiment Analysis.