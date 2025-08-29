import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  ); // Fixed constructor

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Email & Password Sign In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during sign in');
      return null;
    } catch (e) {
      _setError('An unexpected error occurred');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Email & Password Registration
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _setError(null);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during registration');
      return null;
    } catch (e) {
      _setError('An unexpected error occurred');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      // Use signInSilently first, then fallback to signIn
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently() ??
          await _googleSignIn.signIn(); // Fixed method name

      if (googleUser == null) {
        _setError('Google sign in was cancelled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!, // Fixed getter
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during Google sign in');
      return null;
    } catch (e) {
      _setError('An unexpected error occurred');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Phone Authentication
  Future<void> verifyPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    try {
      _setLoading(true);
      _setError(null);
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(e.message);
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // Verify Phone Code
  Future<UserCredential?> verifyPhoneCode(
    String verificationId,
    String smsCode,
  ) async {
    try {
      _setLoading(true);
      _setError(null);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Invalid verification code');
      return null;
    } catch (e) {
      _setError('An unexpected error occurred');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Anonymous Sign In
  Future<UserCredential?> signInAnonymously() async {
    try {
      _setLoading(true);
      _setError(null);
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An error occurred during anonymous sign in');
      return null;
    } catch (e) {
      _setError('An unexpected error occurred');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);
      final isSignedInWithGoogle =
          await _googleSignIn.isSignedIn(); // Fixed method name
      if (isSignedInWithGoogle) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      _setError('An error occurred during sign out');
    } finally {
      _setLoading(false);
    }
  }
}
