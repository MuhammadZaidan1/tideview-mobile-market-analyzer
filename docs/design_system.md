# DESIGN SYSTEM - TIDEVIEW

## 1. DESIGN STYLE
**Design Style Name:** Modern Soft FinTech (Dynamic Accent, Clean Overlap, Light/Dark Adaptive).

**Characteristics:**
* Dominated by Soft/Neutral Backgrounds (adaptif untuk Light/Dark Mode).
* Dynamic Color accents (Bisa dikustomisasi, default premium purple).
* Overlapping layout design (memberikan ilusi depth/kedalaman).
* Super soft rounded corners (ramah pengguna, tidak kaku).
* Floating Capsule Navigation: Bar navigasi bawah melayang (tidak menempel ke tepi pinggir/bawah layar) dan simetris, memberikan kesan rapi, modern, dan bebas bug overflow ala aplikasi Web3/iOS.

**Visual Direction:** * Profesional, modern, dan tidak mengintimidasi.
* Elegan di Light Mode, glowing di Dark Mode.

---

## 2. DESIGN PRINCIPLES
* **Accuracy Over Decoration:** Data adalah bintang utamanya. Desain tidak boleh mengganggu pembacaan angka harga.
* **Speed of Information:** Informasi paling penting (harga & persentase) harus bisa ditangkap mata dalam < 1 detik.
* **Haptic & Taktil:** Setiap interaksi penting harus dirasakan oleh pengguna (via getaran HP), bukan cuma dilihat.
* **Native-First:** UI harus terasa seperti bagian integral dari OS Android (mendukung widget dan sistem navigasi sistem).

---

## 3. COLOR SYSTEM

**Primary Background (Adaptive Light/Dark)**
* **Light Mode:** `#F8F9FA` (Soft Greyish White - background utama), `#FFFFFF` (Surface/Card).
* **Dark Mode:** `#121212` (Deep Charcoal - background utama), `#1E1E1E` (Surface/Card).

**Dynamic Brand Accent (Tide Themes)**
Aplikasi mendukung 5 tema aksen warna yang bisa dikustomisasi oleh pengguna melalui halaman Settings:
* **Theme 1: Royal Purple (Default)** -> Primary: `#7A52F4` | Secondary: `#9B7EFA`
* **Theme 2: Cyber Green** -> Primary: `#00D26A` | Secondary: `#4ADE80`
* **Theme 3: Sunset Orange** -> Primary: `#FF6D00` | Secondary: `#FF9E40`
* **Theme 4: Electric Cyan** -> Primary: `#00D1FF` | Secondary: `#63E2FF`
* **Theme 5: Hot Magenta** -> Primary: `#FF2A7A` | Secondary: `#FF73A3`

*Digunakan untuk:* Header background, tombol CTA utama, indikator titik (dot indicator) dan icon highlight pada Capsule Nav Bar yang sedang aktif, serta focus state border.

**Semantic Colors (Market Indicators)**
* **Bullish/Up:** `#00C853` (Emerald Green).
* **Bearish/Down:** `#FF1744` (Crimson Red).
* **Neutral/Warning:** `#FFB300` (Amber).

**Text Colors**
* **High Emphasis:** `#111111` (Light Mode) / `#FFFFFF` (Dark Mode).
* **Medium Emphasis:** `#8D8D8D` (Secondary Info/Label).

---

## 4. TYPOGRAPHY
**Primary Font Family:** Inter (Google Fonts).
*Why Inter?* Wajib mengaktifkan fitur Tabular Figures (Font feature settings: 'tnum'). Ini memastikan angka 1 dan 8 punya lebar yang sama sehingga daftar harga tidak "goyang" saat angka berubah.

**Hierarchy:**
* **Display Price:** 32pt - 40pt (Bold, Tabular).
* **Heading (Asset Name):** 18pt - 20pt (Semi-Bold).
* **Body Text:** 14pt (Regular).
* **Caption/Label:** 12pt (Medium).
* **Button Text:** 16pt (Bold, All-caps/Sentence case).

---

## 5. SPACING & SHAPE SYSTEM
* **Base Unit:** 8px.
* **Standard Padding:** 20px - 24px (Layar mobile terasa lebih lega).
* **Border Radius (Core Rule):** 24px hingga 32px untuk kartu besar dan bottom sheet. 16px untuk elemen kecil. Sudut harus sangat membulat (Super Soft Radius).

---

## 6. COMPONENT SYSTEM

### 6.1 BUTTONS
* **Primary Button:** Background: Gradient Active Theme Color. Text: `#FFFFFF`. Radius: 999px (Pill-shape) atau 24px.
* **Secondary/Icon Button:** Background: Active Theme Color transparan (Opacity 10-15%). Icon: Active Theme Color.

### 6.2 ASSET CARDS & HEADER (DASHBOARD)
* **Header:** Blok warna Active Theme Color di area paling atas (nempel status bar), berisi total balance atau status koneksi.
* **Asset Cards:** Warna putih solid (Light Mode) / `#1E1E1E` (Dark Mode), ditumpuk (overlapping) sedikit di atas batas warna Header ungu. Radius 24px. Soft drop shadow.

### 6.3 INPUTS & SEARCH
* **Style:** Filled/Underlined minimal.
* **Focus State:** Border menggunakan Active Theme Color.
* **Interaction:** Tampilkan keyboard dengan "Done/Search" action.

### 6.4 BOTTOM NAVIGATION BAR
* **Style:** Floating Capsule / Pill-Shaped Nav Bar. Bar navigasi berbentuk kapsul bulat penuh (radius besar) yang melayang di atas background dengan efek drop shadow lembut dan sedikit transparansi (alpha 0.95). Tidak menggunakan Notch (lengkungan ke dalam).
* **Layout:** Memuat 4 menu utama secara simetris dan sejajar (Dashboard, Markets, Convert, Settings) untuk menjaga keseimbangan visual.
* **Active State:** Menggunakan warna Active Theme Color pada icon, disertai dot indicator (titik kecil) di bawah icon untuk penanda halaman aktif.
* **Center Action:** (Dihapus/Tidak Ada). Fitur Convert disejajarkan sebagai menu ke-3 di dalam kapsul, membuang penggunaan Floating Action Button (FAB) terpisah demi UI yang lebih rata dan tidak rawan terpotong (overflow).

---

## 7. ICON & CHART STYLE
* **Icons:** Feather Icons / Lucide (Outline). Menggunakan background kotak bersudut bulat dengan warna aksen transparan agar lebih rapi.
* **Chart Line:** Gradasi Active Theme Color dengan area fill transparan (0.15 opacity) di bagian bawah garis.
* **Candlestick:** Body Emerald/Crimson murni tanpa border.

---

## 8. INTERACTION & MOTION
* **Shimmer Effect:** Mengalir dari kiri ke kanan pada kartu aset saat data pertama kali ditarik.
* **Page Transition:** Slide Horizontal (Standard Android) atau Fade-through.
* **Haptic Patterns:**
    * Selection Change: Getaran sangat ringan (Light Impact).
    * Price Alert Trigger: Getaran berulang (Uradiating).
    * Error: Getaran ganda (Heavy Impact).

---

## 9. NATIVE ANDROID SPECIFICS
* **Widget Style:** Mengikuti sistem "Material You" Android (Radius besar, warna menyesuaikan wallpaper atau tetap Dark Mode).
* **Notification:** Rich Notification dengan aksi cepat "View Chart" atau "Dismiss".

---

## 10. DO & DON'T

### DO
* Gunakan kontras tinggi untuk angka.
* Gunakan Tabular Numbers selalu.
* Berikan whitespace yang cukup antar kartu aset.
* Pastikan area klik tombol minimal 48x48 dp.

### DON'T
* Jangan gunakan True Black `#000000` sebagai background (bikin mata cepat lelah).
* Jangan gunakan font Serif (terlalu lambat dibaca untuk data finansial).
* Jangan pakai animasi yang terlalu panjang (aplikasi finansial harus terasa instan).
* Jangan taruh terlalu banyak warna selain Hijau/Merah di satu layar.