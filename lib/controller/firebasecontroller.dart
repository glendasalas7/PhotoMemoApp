import 'dart:io';
import 'package:L3P1/model/constant.dart';
import 'package:L3P1/model/photocomment.dart';
import 'package:L3P1/model/photolike.dart';
import 'package:L3P1/model/photomemo.dart';
import 'package:L3P1/model/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseController {
  static Future<User> signIn(
      {@required String email, @required String password}) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  }

  static Future<void> createAccount(
      {@required String email, @required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> createProfile(Profile profile) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PROFILE)
        .add(profile.serialize());
    return ref.id;
  }

  static Future<List<Profile>> getProfileList() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PROFILE)
        .orderBy(Profile.USER_EMAIL, descending: true)
        .get();

    var result = <Profile>[];
    querySnapshot.docs.forEach(
      (doc) {
        result.add(Profile.deserialize(doc.data(), doc.id));
      },
    );
    return result;
  }

  static Future<List<Profile>> getOneProfile(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PROFILE)
        .where(Profile.USER_EMAIL, isEqualTo: email)
        .get();

    var result = <Profile>[];
    querySnapshot.docs.forEach(
      (doc) {
        result.add(Profile.deserialize(doc.data(), doc.id));
      },
    );
    return result;
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.serialize());
    return ref.id;
  }

  static Future<String> addPhotoComment(PhotoComment comment) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COMMENT)
        .add(comment.serialize());
    return ref.id;
  }

  static Future<String> addPhotoLike(PhotoLike like) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_LIKE)
        .add(like.serialize());
    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach(
      (doc) {
        result.add(PhotoMemo.deserialize(doc.data(), doc.id));
      },
    );
    return result;
  }

  static Future<List<PhotoComment>> getPhotoCommentList(
      {@required String originalPoster, @required String memoId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COMMENT)
        .where(PhotoComment.ORIGINAL_POSTER, isEqualTo: originalPoster)
        .where(PhotoComment.PHOTOMEMO_ID, isEqualTo: memoId)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoComment>[];
    querySnapshot.docs.forEach(
      (doc) {
        result.add(PhotoComment.deserialize(doc.data(), doc.id));
      },
    );
    return result;
  }

  static Future<List<dynamic>> getImageLabels(
      {@required File photoFile}) async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler cloudLabeler =
        FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels =
        await cloudLabeler.processImage(visionImage);
    List<dynamic> labels = <dynamic>[];
    for (ImageLabel label in cloudLabels) {
      if (label.confidence >= Constant.MIN_ML_CONFIDENCE)
        labels.add(label.text.toLowerCase());
    }
    return labels;
  }

  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String filename,
    @required String uid,
    @required Function listener,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: filename,
    };
  }

  static Future<void> updatePhotoMemo(
      String docId, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docId)
        .update(updateInfo);
  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docId)
        .delete();

    await FirebaseStorage.instance.ref().child(p.photoFilename).delete();
  }

  static Future<List<PhotoMemo>> searchImage(
      {@required String createdBy, @required List<String> searchLabels}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
    var results = <PhotoMemo>[];
    querySnapshot.docs.forEach(
        (doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));
    return results;
  }
}
