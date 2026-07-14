import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'custom_bottom_nav.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/markets/markets_screen.dart';
import '../../features/convert/convert_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../core/providers/api_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;
  late PageController _pageController;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const MarketsScreen(),
    const ConvertScreen(),
    const SettingsScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch (bukan cuma read) supaya subscription realtime Supabase ke table
    // `assets` tetap aktif selama MainLayout ini kebuka (praktis: selama app
    // dipakai). Value-nya sendiri gak dipakai langsung di sini -- efeknya
    // cuma invalidate cryptoDataProvider/forexDataProvider/stockDataProvider
    // di dalam provider itu sendiri tiap ada perubahan data.
    ref.watch(realtimeAssetsProvider);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}
