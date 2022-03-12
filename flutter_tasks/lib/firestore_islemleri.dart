import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
class FireStoreIshlemleri extends StatefulWidget {
  const FireStoreIshlemleri({Key key}) : super(key: key);

  @override
  _FireStoreIshlemleriState createState() => _FireStoreIshlemleriState();
}
final FirebaseFirestore _firestore =FirebaseFirestore.instance;
PickedFile _secilenResm;
class _FireStoreIshlemleriState extends State<FireStoreIshlemleri> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firestore Ishlemleri"),),
      body: Center(child:
      Column(children: <Widget>[
        RaisedButton(child:Text("Veriekle"),onPressed: _verEkle,color: Colors.pink,),
        RaisedButton(child:Text("Transition ekle"),onPressed: _transitonEkle,color: Colors.indigo,),
        RaisedButton(child:Text("Oxu "),onPressed: _veriOku,color: Colors.lightBlue,),
        RaisedButton(child:Text("Oxu "),onPressed: _veriSorgula,color: Colors.lightBlue,),
        RaisedButton(child:Text("Galeriden resm yukle "),onPressed: _galeriResm,color: Colors.lightBlueAccent,),
        RaisedButton(child:Text("Resm Cek"),onPressed: _resmCek,color: Colors.brown,),
         Expanded(child: _secilenResm==null ?Text("Resm yoxdur"):Image.file(File(_secilenResm.path)),)
      ],),),
    );
  }

  void _verEkle() {
    Map<String,dynamic> emreEkle =Map();
    emreEkle['ad'] ="emre updated";
    emreEkle['lisans'] =true;
    _firestore.collection("users").doc("elmir_qasimzade").set(emreEkle,SetOptions(merge: true)).then((value) => debugPrint("emre eklendi"));
    _firestore.collection("users").doc("hasan").set({'ad':'Hasan','cins':'erkek'}).whenComplete(() => debugPrint("hasan eklendi"));
    _firestore.doc("/users/ayse").set({'ad':'ayse'});
    _firestore.collection("users").add({'add':'Elmir','yas':34});
    String yeniKullaniciId =_firestore.collection("users").doc().id;
    debugPrint("yeni doc id:$yeniKullaniciId");
    _firestore.doc("users/$yeniKullaniciId").set({'yas':30});
    _firestore.doc("users/elmir_qasimzade").update({'okul':'ege universiteti','eklenme':FieldValue.serverTimestamp()}).then((value){
      debugPrint("emre guncellendi");
    });
  }

  void _transitonEkle() async {
    final DocumentReference emreRef =_firestore.doc("users/elmir_qasimzade");
    _firestore.runTransaction((Transaction transaction) async{
     DocumentSnapshot emreData=await emreRef.get();
     if(emreData.exists){
       var emreninParasi =emreData.data()['para'];
     if(emreninParasi >=100){
         await transaction.update(emreRef, {'para':emreninParasi -100});
         await  transaction.update(_firestore.doc("users/hasan"), {'para':FieldValue.increment(100)});
     }else{
       debugPrint("yetersiz bakiye");
     }
     }else{
       debugPrint("elmir yoxdur");
     }
    });
  }

  void _veriSil() {
    _firestore.doc("users/ayse").delete().then((value){debugPrint("ayshe silindi");}).catchError(()=>debugPrint("silerken xeta bash verdi"));
  }

  void _veriOku()  async{
  DocumentSnapshot documentSnapshot = await  _firestore.doc("users/elmir_qasimzade").get();
  debugPrint("doc id:"+documentSnapshot.id);
  debugPrint("doc var mi:"+documentSnapshot.exists.toString());
  debugPrint("document:"+documentSnapshot.toString());
  debugPrint("doc bekleyen yazma varmi:"+documentSnapshot.metadata.hasPendingWrites.toString());
  debugPrint("cachden mi geldi:"+documentSnapshot.data().toString());
  debugPrint("cachden mi geldi:"+documentSnapshot.data()['ad'].toString());
  documentSnapshot.data().forEach((key, deger) { debugPrint("key:$key deger:$deger");});
  _firestore.collection("users").get().then((querySnapshots) {
    debugPrint(querySnapshots.docs.length.toString());
    for(int i =0;i<querySnapshots.docs.length;i++){
      debugPrint(querySnapshots.docs[i].data().toString());
    }
    var ref =_firestore.collection("users").doc("elmir_qasimzade").snapshots();
    ref.listen((degiseVeri) {
      debugPrint("anlik:"+degiseVeri.data().toString());
    });
  });





  }

  void _veriSorgula()async {
 var dokumanlar =  await _firestore.collection("users").where("email",isEqualTo: 'emre.bdu12@gmail.com').get();
 for(var dokuman in dokumanlar.docs){
  debugPrint(dokuman.data().toString());
 }
 var limitliGetir= await _firestore.collection("users").limit(2).get();

 for(var dokuman in limitliGetir.docs){
   debugPrint(dokuman.data().toString());
 }
 var stirngSorgu =await _firestore.collection("users").orderBy("email").startAt(['elmir']).get();
 for(var dokuman in stirngSorgu.docs){
   debugPrint(dokuman.data().toString());
 }
  }

  void _galeriResm() async {
    var _picker = ImagePicker();
    var resim = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _secilenResm = resim;
    });

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child("user")
        .child("emre")
        .child("profil.png");
    firebase_storage.UploadTask uploadTask = ref.putFile(File(_secilenResm.path));

    var url = await ref.getDownloadURL();
    debugPrint("upload edilen resmin urlsi : " + url);
  }

  void _resmCek()async {
    var resm =await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _secilenResm =resm;
    });
    firebase_storage.Reference ref =  firebase_storage.FirebaseStorage.instance.ref().child("user").child("elvin").child("profile.png");
    firebase_storage.UploadTask uploadTask =   ref.putFile(File(_secilenResm.path));

      var url=await (await ref.getDownloadURL()).toString();
    debugPrint("Upload edilen resm url:"+url);

  }
}
