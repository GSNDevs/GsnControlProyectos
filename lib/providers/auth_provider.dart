import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class User {
  final String id;
  final String email;
  final String role; // 'admin', 'staff', 'client'

  const User({required this.id, required this.email, required this.role});
}

class AuthNotifier extends Notifier<User?> {
  final _supabase = supa.Supabase.instance.client;

  @override
  User? build() {
    // Listen to auth state changes to keep the provider up to date
    _supabase.auth.onAuthStateChange.listen((data) {
      final supa.AuthChangeEvent event = data.event;
      final supa.Session? session = data.session;

      if (event == supa.AuthChangeEvent.signedIn ||
          event == supa.AuthChangeEvent.initialSession) {
        if (session != null) {
          _fetchAndSetUser(session.user);
        }
      } else if (event == supa.AuthChangeEvent.signedOut) {
        state = null;
      }
    });

    // Check initial session synchronously if possible, or trigger async fetch
    final session = _supabase.auth.currentSession;
    if (session != null) {
      // Return a temporary user, or use a FutureProvider for init.
      // Since build must be sync or return Future for AsyncNotifier,
      // we'll fetch asynchronously and update state.
      _fetchAndSetUser(session.user);
    }
    return null;
  }

  Future<void> _fetchAndSetUser(supa.User authUser) async {
    try {
      final profile = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', authUser.id)
          .maybeSingle();

      final role = profile != null ? profile['role'] as String : 'staff';

      state = User(id: authUser.id, email: authUser.email ?? '', role: role);
    } catch (e) {
      print("Error fetching user profile: $e");
      // Fallback or handle error
      state = User(id: authUser.id, email: authUser.email ?? '', role: 'staff');
    }
  }

  Future<void> login(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
    // The onAuthStateChange listener will handle updating the state.
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    state = null;
  }

  bool get isAuthenticated => state != null;
}

final authProvider = NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
