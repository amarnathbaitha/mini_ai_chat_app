import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return credential.user!;
  }

  Future<User> signInWithGoogle() async {
    await googleSignIn.initialize();

    final GoogleSignInAccount googleUser =
    await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
    googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final User? currentUser = _firebaseAuth.currentUser;

    UserCredential userCredential;

    if (currentUser != null && currentUser.isAnonymous) {
      userCredential =
      await currentUser.linkWithCredential(credential);
    } else {
      userCredential =
      await _firebaseAuth.signInWithCredential(credential);
    }

    return userCredential.user!;
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }
}
