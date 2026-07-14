// Smoke test dasar -- mastiin app bisa boot tanpa crash sampai ke AuthGate,
// dibungkus ProviderScope (yang lama gak ada ProviderScope, makanya crash).
//
// Ini sengaja dibikin minimal (bukan test lengkap per-fitur) -- cukup buat
// jadi sinyal awal kalau ada perubahan yang bikin app gagal boot sama sekali.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tideview/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Kasih waktu buat theme provider & auth state resolve pertama kali
    await tester.pump(const Duration(seconds: 1));

    // Cukup pastikan ada MaterialApp yang ke-render (app gak crash/blank),
    // gak perlu assert screen spesifik karena AuthGate bisa nampilin
    // WelcomeScreen atau MainLayout tergantung status login/guest.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
