import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/Providers/firebase_providers.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Core/type_def.dart';

//* this will allow us to store a file
final storageRepProvider = Provider(
  (ref) => StorageRepository(
    firebaseStorage: ref.watch(
        storageProvider), //*storageProvider contains the instance of firebase storage
  ),
);

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFile(
      {required String path,
      required String id,
      required File? file,
      required Uint8List? webFile}) async {
    try {
      //!the reference will point to the root of the storage bucket
      final ref = _firebaseStorage.ref().child(path).child(id);

      //!A class which indicates an on-going upload task
      UploadTask uploadTask;
//**FOR WEB**//
      if (kIsWeb) {
        uploadTask = ref.putData(webFile!);
      } else {
        uploadTask = ref.putFile(file!);
      }
//!returned as the result or on-going process of a [Task].
      final snapshot = await uploadTask;

//?fetch the downloadUrl from which file is being uploaded.
//?from this we can successfully upload our file in correct location =>
//?_firebaseStorage.ref().child(path).child(id);
//?it will get into the firebase data base and display it to all the users
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
