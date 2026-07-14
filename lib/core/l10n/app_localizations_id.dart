// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get dashboard => 'Dasbor';

  @override
  String get markets => 'Pasar';

  @override
  String get convert => 'Konversi';

  @override
  String get settings => 'Pengaturan';

  @override
  String get emptyCategoryMessage =>
      'Kategori kosong. Tambahkan aset dari Markets.';

  @override
  String get greeting => 'TideView';

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
  String get exploreMarkets => 'Jelajahi Pasar';

  @override
  String get searchAssets => 'Cari aset...';

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
  String get systemDefault => 'Default';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get themeColor => 'Warna Tema';

  @override
  String get selectThemeColor => 'Pilih warna tema';

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
  String get cacheSubtitle => 'Bebaskan ruang penyimpanan';

  @override
  String get cacheSuccess => 'Cache berhasil dibersihkan.';

  @override
  String get preparingImage => 'Menyiapkan gambar...';

  @override
  String shareMessage(String name, String price) {
    return 'Memantau harga $name di TideView.\nHarga saat ini $price.';
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
  String get chartResting => 'Grafik tidak aktif';

  @override
  String get noChartData => 'Tidak ada data grafik';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String get marketStats => 'Statistik Pasar';

  @override
  String get marketType => 'Tipe Pasar';

  @override
  String get lastUpdated => 'Terakhir Diperbarui';

  @override
  String get shareCard => 'Bagikan kartu';

  @override
  String get selectAsset => 'Pilih aset';

  @override
  String get assetNotFound => 'Aset tidak ditemukan.';

  @override
  String get offlineModeMessage => 'Mode offline — menampilkan data tersimpan';

  @override
  String get setPriceAlert => 'Pasang alert harga';

  @override
  String get priceAlertDescription =>
      'Terima notifikasi saat harga mencapai target.';

  @override
  String get selectAssetLabel => 'Pilih aset';

  @override
  String get chooseAssetHint => 'Pilih aset...';

  @override
  String get conditionLabel => 'Kondisi';

  @override
  String get priceGoesAbove => 'Naik ke';

  @override
  String get priceGoesBelow => 'Turun ke';

  @override
  String get alertSavedSuccess => 'Alert berhasil disimpan';

  @override
  String get setAlarmButton => 'Pasang alert';

  @override
  String get widgetSyncRate => 'Frekuensi sinkronisasi widget';

  @override
  String get sync15Min => '15 Menit';

  @override
  String get sync30Min => '30 Menit';

  @override
  String get sync1Hour => '1 Jam';

  @override
  String get widgetManagement => 'Manajemen Widget';

  @override
  String get selectedAsset => 'Aset terpilih';

  @override
  String get notifications => 'Notifikasi';

  @override
  String get manageAlerts => 'Kelola alert';

  @override
  String get noAlertsSet => 'Belum ada alert';

  @override
  String get priceAbove => 'Di atas';

  @override
  String get priceBelow => 'Di bawah';

  @override
  String get addAlert => 'Tambah alert';

  @override
  String get clearCacheConfirmTitle => 'Hapus cache?';

  @override
  String get clearCacheConfirmMessage =>
      'Hapus semua data cache?\nTindakan ini tidak dapat dibatalkan.';

  @override
  String get yesClear => 'Ya, hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get ok => 'OK';

  @override
  String get createNewCategory => 'Buat Kategori Baru';

  @override
  String get categoryExample => 'misal, Saham Tech, Kripto...';

  @override
  String get save => 'Simpan';

  @override
  String get editCategory => 'Edit Kategori';

  @override
  String get emptyWatchlistMessage => 'Watchlist kosong. Tambahkan aset dulu.';

  @override
  String get editAssets => 'Edit Aset';

  @override
  String get reorderList => 'Urutkan Daftar';

  @override
  String get deleteCategory => 'Hapus Kategori';

  @override
  String get categoryCreatedTitle => 'Sukses';

  @override
  String get categoryCreatedMessage => 'Kategori berhasil dibuat.';

  @override
  String get deleteCategoryConfirmTitle => 'Hapus Kategori?';

  @override
  String get deleteCategoryConfirmMessage =>
      'Yakin ingin menghapus kategori ini? Aset di dalamnya akan tetap aman.';

  @override
  String get yesDelete => 'Ya, hapus';

  @override
  String get forexIntradayNotAvailable =>
      'Data harian (Intraday) tidak tersedia untuk Forex.';

  @override
  String get welcomeTitle => 'Selamat Datang di TideView';

  @override
  String get welcomeSubtitle =>
      'Pantau crypto, saham, dan forex secara real-time';

  @override
  String get continueAsGuest => 'Lanjut sebagai Tamu';

  @override
  String get continueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get continueWithGithub => 'Lanjutkan dengan GitHub';

  @override
  String get loginTitle => 'Login dulu yuk';

  @override
  String get loginSubtitle =>
      'Buat sync watchlist & alert kamu antar perangkat';

  @override
  String get manageAccount => 'Kelola Akun';

  @override
  String get loggedInAs => 'Masuk sebagai';

  @override
  String get notLoggedIn => 'Belum login';

  @override
  String get notLoggedInSubtitle => 'Sync watchlist & alert belum aktif';

  @override
  String get tapToLogin => 'Tap untuk login';

  @override
  String get logOut => 'Keluar';

  @override
  String get logOutConfirmTitle => 'Keluar dari akun?';

  @override
  String get logOutConfirmMessage =>
      'Kamu akan kembali ke mode tamu. Data lokal di perangkat ini tetap aman.';

  @override
  String get yesLogOut => 'Ya, keluar';

  @override
  String get loginFailed => 'Login gagal';
}
