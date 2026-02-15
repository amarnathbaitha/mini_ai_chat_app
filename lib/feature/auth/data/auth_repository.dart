import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User> signInAnonymously() async {
    final credential = await _firebaseAuth.signInAnonymously();
    return credential.user!;
  }

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Future<User> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    final GoogleSignInAccount? googleUser =
    await googleSignIn.authenticate();

    if (googleUser == null) {
      throw Exception("Google Sign-In cancelled");
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    UserCredential userCredential;

    // 🔥 IMPORTANT: Link if anonymous
    if (currentUser != null && currentUser.isAnonymous) {
      userCredential =
      await currentUser.linkWithCredential(credential);
    } else {
      userCredential =
      await auth.signInWithCredential(credential);
    }

    return userCredential.user!;
  }




  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
