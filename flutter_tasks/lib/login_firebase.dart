import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
FirebaseAuth _auth = FirebaseAuth.instance;
class LoginIslemleri extends StatefulWidget {
  const LoginIslemleri({Key key}) : super(key: key);

  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        print('Istifadeci oturumunu baqladi');
      } else {
        print('Oturum acdi');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Email/shifre"),
              color: Colors.lightBlue,
              onPressed: _emailSifreKulaniciYarat,
            ),
            RaisedButton(
              child: Text("Email/shifre usr giris"),
              color: Colors.indigoAccent,
              onPressed: _emailSifreKulaniciGiris,
            ),
            RaisedButton(
              child: Text("Hesabdan cix"),
              color: Colors.lightBlueAccent,
              onPressed: _cixisYap,
            ),
            RaisedButton(
              child: Text("Shifremi unutdum"),
              color: Colors.lightBlueAccent,
              onPressed: _resetPassword,
            ),
            RaisedButton(
              child: Text("Shifremi guncelle"),
              color: Colors.pink,
              onPressed: _updatePassword,
            ),
            RaisedButton(
              child: Text("Emailimi guncelle"),
              color: Colors.pink,
              onPressed: _updateEmail,
            ),
            RaisedButton(
              child: Text("gOOGLE İLE GİRİS"),
              color: Colors.indigo,
              onPressed: _signInWithGoogle,
            ),
            RaisedButton(
              child: Text("Telefon no ile girish"),
              color: Colors.indigo,
              onPressed: _telNoGirish,
            )
          ],
        ),
      ),
    );
  }
  Future<UserCredential> _signInWithGoogle() async {
    try{
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    }catch(e){
      debugPrint("gmail girisi xeta $e");
    }

  }


  void _emailSifreKulaniciGiris() async {
    String _email ="elmir.bdu12@gmail.com";
    String _password ="pasword2w3";
    try{
      if(_auth.currentUser == null){
        User _oturumAcanUser = (await _auth.signInWithEmailAndPassword(email: _email, password: _password)).user;
        if(_oturumAcanUser.emailVerified){
          debugPrint("emailiniz onayli tebrikler");
        }else{
          debugPrint("Mailinizi onaylayib tekrar giris edin");
          _auth.signOut();
        }
      }
      else{
        debugPrint("oturum aciqdir");
      }
    }catch(e){
      debugPrint(e.toString());
    }

  }

  void _cixisYap() async {
    if(_auth.currentUser != null){
      await _auth.signOut();
    }
    else{
      debugPrint("oturum acmisistifadeci yoxdur");
    }

  }
  void _emailSifreKulaniciYarat() async {
    String _email ="elmir.bdu12@gmail.com";
    String _password ="pasword23";
    try{
      UserCredential _credential = await   _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      User _newUser = _credential.user;
      await  _newUser.sendEmailVerification();
      if(_auth.currentUser != null) {
        debugPrint("Maili tesdiqlemelisiniz");
        await _auth.signOut();
      }
      debugPrint(_newUser.toString());
    }
    catch(e){
      debugPrint(e.toString());
    }
  }

  void _resetPassword()  async{
    String _email ="elmir.bdu12@gmail.com";
   try{
     await _auth.sendPasswordResetEmail(email: _email);
     debugPrint("resetleme maili gonderildi");
   }catch(e){
     debugPrint("Sifre resetlenirken hata olusdu $e");
   }
  }

  void _updatePassword()async {
    try{
      await _auth.currentUser.updatePassword("password2");
         debugPrint("shifreniz guncellendi");
    }catch(e){
      String email = 'elmir.bdu12@gmail.com';
      String password = 'password2';

// Create a credential
      EmailAuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential);
      debugPrint("guncellenenmedi $e");
    }
  }

  void _telNoGirish() async{
    await _auth.verifyPhoneNumber(
      phoneNumber: '+994 77 384 08 09',
      verificationCompleted: (PhoneAuthCredential credential)async {
        await _auth.signInWithCredential(credential);

      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int resendToken) async{
        String smsCode = '2345';

        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
        await _auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}


  void _updateEmail()  async{
    try{
      await _auth.currentUser.updateEmail("elmir@elmir.vom");
      debugPrint("shifreniz guncellendi");
    }catch(e){
      String email = 'elmir.bdu12@gmail.com';
      String password = 'password2';

// Create a credential
      EmailAuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential);
      debugPrint("guncellenenmedi $e");
    }
  }

