import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// Stream auth state Supabase -- watch ini di widget mana pun yang perlu
/// rebuild otomatis pas user login/logout (misal Settings screen).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

/// Shortcut buat ambil User saat ini (null kalau guest/belum login).
/// Dependent ke authStateProvider supaya ikut ke-rebuild pas auth berubah.
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return supabase.auth.currentUser;
});
