import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  var user;

  Future<String> getCurrentUID() async {
    User user = FirebaseAuth.instance.currentUser!;
    return user.uid;
  }

  Future<bool> checkAuth() async {
    try {
      user = _firebaseAuth.currentUser;
      if (user != null) {
        print("Signed In");
        return true;
      } else {
        print("No User");
        return false;
      }
    } catch (e) {
      print("Error");
      return false;
    }
  }

  Future<String> signIn(String email, String password) async {
    String message = "";
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return message = "SignedIn";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("user not found.");
        message = "NoUser";
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        message = "IncorrectPassword";
      }
      return message;
    }
  }

  Future<String> register(String email, String password) async {
    String message = "";
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return message = "Registered";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        message = "WeakPassword";
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        message = "AccountAlreadyExist";
      }
      return message;
    } catch (e) {
      print(e);
      return message = e.toString();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut().then((value) => print("Signed Out"));
  }
}
