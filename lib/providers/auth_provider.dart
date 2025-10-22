import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  int _userPoints = 0;

  User? get user => _user;
  int get userPoints => _userPoints;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (_user != null) {
        _fetchUserPoints();
      } else {
        _userPoints = 0;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserPoints() async {
    if (_user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();

    if (doc.exists && doc.data()!.containsKey('points')) {
      _userPoints = doc.data()!['points'] as int;
    } else {
      _userPoints = 0; // Default if no points field
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .set({'points': 0}, SetOptions(merge: true));
    }

    notifyListeners();
  }

  Future<String?> signUpWithEmailAndPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's profile with their name
      await userCredential.user?.updateDisplayName('$firstName $lastName');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({'points': 0}, SetOptions(merge: true));

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // The user canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({'points': 0}, SetOptions(merge: true));
        }
        // No need to call _fetchUserPoints() here, the authStateChanges listener will handle it.
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow; // Rethrow to allow the UI to handle the error
    } catch (e) {
      debugPrint('An unexpected error occurred during Google sign-in: $e');
      rethrow; // Rethrow to allow the UI to handle the error
    }
  }

  Future<void> addPoints(int amount) async {
    if (_user == null) return;

    _userPoints += amount;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .update({'points': _userPoints});

    notifyListeners();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
