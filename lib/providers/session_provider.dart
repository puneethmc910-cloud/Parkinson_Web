import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/firebase_service.dart';

class SessionProvider extends ChangeNotifier {
  final FirebaseService firebaseService;

  User? _user;
  bool _loading = false;
  String? _error;

  SessionProvider({required this.firebaseService}) {
    firebaseService.auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await firebaseService.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Authentication failed';
    } catch (_) {
      _error = 'Unknown error occurred';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await firebaseService.signOut();
  }
}


