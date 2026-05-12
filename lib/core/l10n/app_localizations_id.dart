// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'TideView';

  @override
  String get welcome => 'Selamat datang kembali';

  @override
  String get dashboard => 'Dasbor';

  @override
  String get markets => 'Pasar';

  @override
  String get convert => 'Konversi';

  @override
  String get settings => 'Pengaturan';

  @override
  String get createNewCategory => 'Buat Kategori Baru';

  @override
  String get categoryExample => 'Contoh: Koin Galau, Jangka Panjang';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get editCategory => 'Edit Kategori';

  @override
  String get emptyWatchlistMessage =>
      'Watchlist utama masih kosong.\nTambahkan dulu koin dari Pasar!';

  @override
  String get editAssets => 'Edit Aset';

  @override
  String get reorderList => 'Susun Ulang Daftar';

  @override
  String get deleteCategory => 'Hapus Kategori';

  @override
  String get greeting => 'Halo, Zaidan!';

  @override
  String get onlineStatus => 'Online';

  @override
  String get allCategory => 'Semua';

  @override
  String get cryptoCategory => 'Kripto';

  @override
  String get stocksCategory => 'Saham';

  @override
  String get forexCategory => 'Forex';

  @override
  String get failedToLoadData => 'Gagal memuat data';

  @override
  String get emptyCategoryMessage =>
      'Watchlist kosong di kategori ini.\nCari dan tambahkan favorit dari menu Pasar.';

  @override
  String get sortBy => 'Urutkan Berdasarkan';

  @override
  String get sortByName => 'Nama (A - Z)';

  @override
  String get topGainers => 'Top Gainers (🔥)';

  @override
  String get topLosers => 'Top Losers (🩸)';

  @override
  String get marketExplorers => 'Penjelajah Pasar';

  @override
  String get searchAssets => 'Cari aset...';

  @override
  String get error => 'Error';

  @override
  String get from => 'Dari';

  @override
  String get to => 'Ke';

  @override
  String get select => 'Pilih';

  @override
  String get calculator => 'Kalkulator';

  @override
  String get marketSnapshot => 'Ringkasan Pasar';

  @override
  String get appearance => 'Tampilan';

  @override
  String get appTheme => 'Tema Aplikasi';

  @override
  String get systemDefault => 'Default Sistem';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get themeColor => 'Warna Tema';

  @override
  String get selectThemeColor => 'Pilih Warna Tema';

  @override
  String get preferences => 'Preferensi';

  @override
  String get language => 'Bahasa';

  @override
  String get baseCurrency => 'Mata Uang Dasar';

  @override
  String get dataManagement => 'Manajemen Data';

  @override
  String get clearCache => 'Bersihkan Cache';

  @override
  String get cacheSubtitle => 'Kosongkan ruang penyimpanan';

  @override
  String get cacheSuccess => 'Cache berhasil dibersihkan! 🚀';

  @override
  String get preparingImage => 'Menyiapkan gambar...';

  @override
  String shareMessage(String name, String price) {
    return 'Lagi pantau harga $name di TideView! Harganya sekarang \$$price. Gimana menurut lu?';
  }

  @override
  String shareFailed(String error) {
    return 'Gagal membagikan gambar: $error';
  }

  @override
  String get addedToWatchlist => 'Ditambahkan ke Watchlist';

  @override
  String get removedFromWatchlist => 'Dihapus dari Watchlist';

  @override
  String get chartResting => 'Grafik Sedang Istirahat';

  @override
  String get unknownError => 'Error tidak diketahui';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get noChartData => 'Tidak ada data grafik';

  @override
  String get marketStats => 'Statistik Pasar';

  @override
  String get marketType => 'Tipe Pasar';

  @override
  String get lastUpdated => 'Terakhir Diperbarui';

  @override
  String get shareCard => 'Bagikan Kartu';

  @override
  String get selectAsset => 'Pilih Aset';

  @override
  String get searchAssetHint => 'Cari aset (BTC, Apple, USD)...';

  @override
  String get assetNotFound => 'Aset tidak ditemukan.';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get offlineModeMessage => 'Mode Offline - Menampilkan data cache';

  @override
  String get setPriceAlert => 'Pasang Alarm Harga';

  @override
  String get priceAlertDescription =>
      'Dapatkan notifikasi push saat harga mencapai target.';

  @override
  String get selectAssetLabel => 'PILIH ASET';

  @override
  String get chooseAssetHint => 'Pilih Aset...';

  @override
  String get conditionLabel => 'KONDISI';

  @override
  String get priceGoesAbove => 'Harga NAIK DI ATAS';

  @override
  String get priceGoesBelow => 'Harga TURUN DI BAWAH';

  @override
  String get targetPriceUsd => 'HARGA TARGET (USD)';

  @override
  String get alertSavedSuccess => 'Alarm berhasil disimpan!';

  @override
  String get setAlarmButton => 'Pasang Alarm';

  @override
  String get widgetSyncRate => 'Frekuensi Sinkronisasi';

  @override
  String get sync15Min => '15 Menit';

  @override
  String get sync30Min => '30 Menit';

  @override
  String get sync1Hour => '1 Jam';

  @override
  String get widgetManagement => 'Manajemen Widget';

  @override
  String get selectedAsset => 'Aset Terpilih';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get manageAlerts => 'Kelola Peringatan Harga';

  @override
  String get noAlerts => 'Belum ada peringatan';

  @override
  String get priceAbove => 'Di atas';

  @override
  String get priceBelow => 'Di bawah';

  @override
  String get alertDeleted => 'Peringatan dihapus';

  @override
  String get exploreMarkets => 'Jelajahi Pasar';
}
