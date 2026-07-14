# TideView — User Guidebook

Panduan lengkap penggunaan TideView, dari pertama kali buka app sampai fitur-fitur lanjutan. Dokumen ini buat end-user (bukan dokumentasi teknis developer — untuk itu, lihat catatan arsitektur di `README.md`).

---

## Daftar Isi

1. [Memulai](#1-memulai)
2. [Navigasi Utama](#2-navigasi-utama)
3. [Dashboard](#3-dashboard)
4. [Markets](#4-markets)
5. [Asset Detail & Chart](#5-asset-detail--chart)
6. [Watchlist & Kategori](#6-watchlist--kategori)
7. [Price Alert](#7-price-alert)
8. [Convert (Kalkulator)](#8-convert-kalkulator)
9. [Settings](#9-settings)
10. [Home Screen Widget](#10-home-screen-widget)
11. [Akun & Cloud Sync](#11-akun--cloud-sync)
12. [Mode Offline](#12-mode-offline)
13. [FAQ & Troubleshooting](#13-faq--troubleshooting)

---

## 1. Memulai

Pas pertama kali buka TideView, kamu bakal disambut **Welcome Screen** dengan 3 pilihan:

| Pilihan | Yang terjadi |
|---|---|
| **Continue as Guest** | Langsung masuk app, semua fitur market bisa dipakai. Watchlist/alert tersimpan cuma di HP ini. |
| **Continue with Google** | Login pakai akun Google, watchlist/alert otomatis sync ke akun. |
| **Continue with GitHub** | Login pakai akun GitHub, sama seperti Google. |

**Gak perlu login buat mulai pakai app.** Login itu opsional — cuma dibutuhin kalau kamu mau data kamu (watchlist, alert, kategori) ikut kesimpen ke akun dan bisa dipulihkan di device lain.

Welcome Screen ini cuma muncul **sekali** — begitu kamu pilih Guest atau berhasil login, app bakal langsung masuk ke Dashboard tiap kali dibuka lagi.

---

## 2. Navigasi Utama

Di bagian bawah layar ada 4 tab:

| Tab | Isinya |
|---|---|
| 🏠 **Dashboard** | Ringkasan watchlist kamu, dikelompokkan per kategori |
| 📊 **Markets** | Browse semua asset (crypto/forex/stocks), search, toggle watchlist |
| 🔄 **Convert** | Kalkulator konversi antar mata uang/asset |
| ⚙️ **Settings** | Tema, bahasa, mata uang dasar, akun, kelola alert |

---

## 3. Dashboard

Halaman pertama yang kamu lihat setiap buka app. Isinya watchlist kamu, dikelompokin per kategori (kalau udah bikin kategori — lihat [bagian 6](#6-watchlist--kategori)).

- **Belum ada watchlist?** Dashboard bakal nampilin ajakan buat explore ke tab Markets dan mulai nambahin asset favorit.
- **Tarik ke bawah (pull-to-refresh)** buat paksa update harga terbaru manual, gak perlu nunggu sync otomatis.
- Harga di Dashboard **update sendiri secara real-time** — begitu ada perubahan harga di server, angka di layar berubah otomatis tanpa kamu refresh apa pun.

---

## 4. Markets

Ini tempat browse **semua** asset yang di-track TideView — crypto, forex, dan saham, digabung jadi satu list yang bisa di-filter per kategori market.

- **Search bar** di atas buat cari symbol/nama spesifik (contoh: ketik "BTC" atau "Bitcoin").
- **Tap ikon bintang** di kartu asset buat nambah/hapus dari watchlist — perubahan ini langsung tersimpan (dan ikut sync ke akun kalau kamu udah login).
- **Tap kartu asset-nya** (bukan bintangnya) buat masuk ke halaman [Asset Detail](#5-asset-detail--chart).

---

## 5. Asset Detail & Chart

Halaman ini nampilin info mendalam soal 1 asset:

- **Harga real-time** dan persentase perubahan 24 jam
- **Chart interaktif** — bisa ganti timeframe (1D, 1W, 1M, 3M, 1Y, ALL) dengan tab di atas chart
- **Tombol bintang** buat toggle watchlist, sama seperti di Markets
- **Tombol "Set Alert"** buat bikin price alert baru (lihat [bagian 7](#7-price-alert))

> **Catatan:** beberapa crypto (biasanya yang baru muncul di top-50 atau kurang populer) mungkin nampilin "No chart data available" — ini bukan error, cuma keterbatasan sumber data historical yang belum nge-cover semua coin.

---

## 6. Watchlist & Kategori

Kamu bisa mengelompokkan watchlist jadi beberapa kategori custom (misal "Long Term", "Day Trading", "Watching Closely").

**Bikin kategori baru:**
1. Buka Settings (atau dari Dashboard, tergantung versi UI) → cari opsi kelola kategori
2. Ketik nama kategori, simpan

**Masukin asset ke kategori:**
1. Dari Markets atau Asset Detail, tap opsi kategori pada asset yang udah di-watchlist
2. Centang/uncentang kategori yang mau di-assign — 1 asset bisa masuk lebih dari 1 kategori

**Urutan kategori** bisa diatur drag-and-drop dari halaman kelola kategori.

---

## 7. Price Alert

Alert bikin kamu dapet notifikasi begitu harga asset nyampe target tertentu.

**Bikin alert baru:**
1. Buka Asset Detail dari asset yang mau di-alert
2. Tap "Set Alert"
3. Isi harga target, pilih arah (Above/naik ke atas target, atau Below/turun ke bawah target)
4. Simpan

**Kelola alert yang udah dibuat:**
- Buka **Settings → Manage Alerts**
- Di situ kelihatan semua alert aktif & yang udah triggered
- Bisa di-toggle aktif/nonaktif, atau dihapus

**Cara kerja notifikasi:** alert dicek secara berkala di background (bahkan kalau app ditutup), lewat proses sync periodik. Kalau harga udah nyentuh target, notifikasi lokal muncul di HP kamu dan alert otomatis jadi nonaktif (biar gak notif berulang-ulang).

---

## 8. Convert (Kalkulator)

Tab ini buat konversi cepat antar mata uang atau ke crypto/saham:
1. Pilih asset asal dan tujuan
2. Ketik jumlah
3. Hasil konversi muncul otomatis pakai harga real-time terbaru

---

## 9. Settings

| Opsi | Fungsi |
|---|---|
| **Account** | Login/logout, kelola akun (lihat [bagian 11](#11-akun--cloud-sync)) |
| **Appearance** | Ganti tema (light/dark/system) dan accent color |
| **Base Currency** | Mata uang dasar buat tampilan harga (USD, IDR, dll) |
| **Language** | Bahasa Indonesia / English |
| **Widget Sync Rate** | Atur seberapa sering home widget update (15/30/60 menit) |
| **Manage Alerts** | Lihat & kelola semua price alert |

---

## 10. Home Screen Widget

TideView punya widget buat home screen Android yang nampilin 1 asset pilihan kamu (harga + perubahan 24 jam) tanpa perlu buka app.

**Cara pasang:**
1. Tekan lama di home screen HP kamu → pilih **Widgets**
2. Cari **TideView**, drag ke home screen
3. Widget otomatis nampilin asset default — buat ganti, atur lewat **Settings** (asset mana yang mau ditampilkan)

Widget update otomatis sesuai interval yang kamu atur di Settings, dan **tap widget-nya** langsung buka Asset Detail asset itu di dalam app.

---

## 11. Akun & Cloud Sync

### Kenapa harus login?

Login **sepenuhnya opsional**. Manfaatnya:
- Watchlist, kategori, dan alert kamu **tersimpan di cloud**, bukan cuma di 1 HP
- Ganti HP atau install ulang app? Tinggal login pakai akun yang sama, semua data balik lagi otomatis
- Kalau tetap pakai Guest mode, semua fitur market tetap 100% bisa dipakai — cuma datanya gak ter-backup ke cloud

### Cara login

Buka **Settings → Account**, pilih **Login**, lalu pilih **Google** atau **GitHub**. Browser/Custom Tabs bakal kebuka buat proses autentikasi, setelah selesai otomatis balik ke app dalam kondisi udah login.

### Cara logout

Buka **Settings → Account → Manage Account**, tap **Log Out**, konfirmasi. Setelah logout, app balik ke mode Guest — data yang udah tersimpan di akun tetap aman di cloud, tinggal login lagi kapan aja buat manggil balik.

### Apa yang tersinkron?

✅ Watchlist (asset yang di-star)
✅ Kategori custom
✅ Price alert

❌ Tema/accent color (ini per-device, gak ikut akun)
❌ Bahasa (per-device)

---

## 12. Mode Offline

TideView didesain **offline-first** — data market terakhir yang berhasil diambil tetap tersimpan lokal di HP, jadi kamu tetap bisa buka app dan lihat harga (yang mungkin agak basi) walau lagi gak ada koneksi internet.

- Kalau lagi offline, muncul banner kecil yang kasih tau statusnya
- Begitu koneksi balik, app otomatis sync ulang tanpa perlu refresh manual
- Toggle watchlist/bikin alert pas offline tetap bisa, tapi baru ke-sync ke cloud begitu online lagi (kalau kamu login)

---

## 13. FAQ & Troubleshooting

**Q: Kenapa ada asset yang gak punya chart historical?**
A: Sumber data chart (khususnya crypto) gak selalu cover semua coin yang ada di list harga. Ini keterbatasan sumber data, bukan bug.

**Q: Saya toggle watchlist pas belum login, terus login — apa data itu ilang?**
A: Enggak. Begitu kamu login, watchlist yang udah dibikin selagi Guest otomatis ikut ke-push ke akun.

**Q: Notifikasi alert gak muncul padahal harga udah kena target?**
A: Pastikan izin notifikasi buat TideView aktif di pengaturan HP, dan app punya izin jalan di background (beberapa HP Android, terutama Xiaomi/Oppo/Vivo, agresif mematikan background process — cek pengaturan baterai/battery optimization buat TideView, whitelist kalau perlu).

**Q: Widget di home screen gak update?**
A: Cek interval sync di Settings, dan pastikan app gak di-force-stop oleh sistem. Sama seperti alert, battery optimization HP tertentu bisa ganggu proses update background.

**Q: Saya logout terus login lagi pakai akun beda — watchlist-nya campur gak?**
A: Enggak, tiap akun punya data watchlist/alert masing-masing yang terpisah total (dilindungi lewat sistem keamanan di level database).