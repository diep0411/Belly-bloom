import 'package:babyweb/model/user_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Get all users
  static Future<List<UserAccount>> getAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(userCollection)
          .get();
      
      return snapshot.docs
          .map((doc) => UserAccount.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }
}
