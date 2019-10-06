import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  //final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<FirebaseUser> get getUser => _auth.currentUser();
  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;


  Future<AuthResult> createUser(String email, String password) async {
    AuthResult result;
    result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    print("User created: ${result.user.email} uid: ${result.user.uid}");
    updateUserData(result.user);
    return result;
  }

  Future<AuthResult> signInPassword(String email, String password) async {
    AuthResult result;
    result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    updateUserData(result.user);
    return result;
  }





  /*
   Future<FirebaseUser> googleSignIn() async {
     try{
       GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
       GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

       final AuthCredential credential = GoogleAuthProvider.getCredential(
         accessToken: googleAuth.accessToken,
         idToken: googleAuth.idToken,
       );

        //FirebaseUser user = await _auth.signInWithCredential(credential);
          FirebaseUser user = await _auth.signInWithCredential(credential);
          updateUserData(user);
     }catch(error){
       print(error);
       return null;
     }
   }
*/


  Future<void> updateUserData(FirebaseUser user) {
    print("User id: ${user.uid}");
    DocumentReference reportRef = _db.collection('reportes').document(user.uid);
    return reportRef.setData({
      'uid': user.uid,
      'correo' : user.email,
      'lastActivity': DateTime.now()
    },merge: true);
  }

  Future<void> signOut(){
    return _auth.signOut();
  }
}
