import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: ganti dengan Project URL & anon/publishable key kamu sendiri
// (Settings -> Data API untuk URL, Settings -> API Keys untuk key).
// Aman ditaruh di client karena semua table dilindungi Row Level Security.
const String supabaseUrl = 'https://hwqywyaeabgcjvxbfgwh.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3cXl3eWFlYWJnY2p2eGJmZ3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4NzQwNDYsImV4cCI6MjA5OTQ1MDA0Nn0.b2orYxB-oRNm3fDQhEHgZSV__ivSq5kjjf9cJ5o6Eks';

/// Shortcut buat akses Supabase client dari mana aja.
SupabaseClient get supabase => Supabase.instance.client;

/// Constant redirect URL buat OAuth deep link -- harus sama persis dengan
/// yang didaftarin di AndroidManifest.xml dan Supabase URL Configuration.
const String oauthRedirectUrl = 'io.tideview.app://login-callback';

Future<void> initSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

/// Null kalau belum login (guest mode).
User? get currentUser => supabase.auth.currentUser;

bool get isLoggedIn => currentUser != null;

Future<void> signInWithGoogle() async {
  await supabase.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: oauthRedirectUrl,
  );
}

Future<void> signInWithGithub() async {
  await supabase.auth.signInWithOAuth(
    OAuthProvider.github,
    redirectTo: oauthRedirectUrl,
  );
}

Future<void> signOut() async {
  await supabase.auth.signOut();
}

/// Helper dipakai bersama oleh crypto/forex/stocks repository buat manggil
/// Edge Function `get-chart-data`. Dipusatkan di sini biar gak duplikasi
/// logic HTTP call + parsing di 3 tempat berbeda.
Future<List<List<double>>> fetchChartDataFromEdgeFunction({
  required String symbol,
  required String marketType,
  required String timeframe,
}) async {
  final url = Uri.parse(
    '$supabaseUrl/functions/v1/get-chart-data'
    '?symbol=$symbol&marketType=$marketType&timeframe=$timeframe',
  );

  final response = await http
      .get(
        url,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      )
      .timeout(const Duration(seconds: 20));

  if (response.statusCode != 200) {
    throw Exception(
      'Gagal ambil chart data ($symbol/$marketType/$timeframe): '
      'HTTP ${response.statusCode}',
    );
  }

  final decoded = json.decode(response.body);
  final List<dynamic> pricesRaw = decoded['prices'] ?? [];

  return pricesRaw
      .map((p) => (p as List).cast<num>().map((n) => n.toDouble()).toList())
      .toList();
}
