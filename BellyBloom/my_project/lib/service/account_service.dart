import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/model/form_collection.dart';
import 'package:my_project/model/user_account.dart';

class AccountService {
  static String userCollection = 'users';
  static Future<UserAccount> login({
    required String email,
    required String password,
  }) async {
    final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userAccount =
        await FirebaseFirestore.instance
            .collection(userCollection)
            .doc(user.user?.uid)
            .get();
    return UserAccount.fromJson(userAccount.data() ?? {}, user.user?.uid ?? '');
  }

  static Future<UserAccount> getUserAccount({required String uid}) async {
    final userAccount =
        await FirebaseFirestore.instance
            .collection(userCollection)
            .doc(uid)
            .get();
    return UserAccount.fromJson(userAccount.data() ?? {}, uid);
  }

  static Future<void> updateUserCollectionForm({
    required FormCollection formCollection,
    required String uid,
  }) async {
    await FirebaseFirestore.instance.collection(userCollection).doc(uid).update(
      {"formCollection": formCollection.toJson()},
    );
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Cập nhật thông tin user (tên)
  static Future<void> updateUserInfo({
    required String uid,
    required String name,
  }) async {
    await FirebaseFirestore.instance.collection(userCollection).doc(uid).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cập nhật cả thông tin user và formCollection
  static Future<void> updateUserAndFormCollection({
    required String uid,
    required String name,
    required FormCollection formCollection,
  }) async {
    await FirebaseFirestore.instance.collection(userCollection).doc(uid).update({
      'name': name,
      'formCollection': formCollection.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
