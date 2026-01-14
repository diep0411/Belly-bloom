import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_project/model/diary_model.dart';
import 'package:my_project/service/base_common.dart';
import 'package:path/path.dart' as path;

class DiaryService {
  static const String collection = 'diaries';
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all diaries for current user
  static Future<List<DiaryModel>> getDiaries() async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return [];

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userUid)
              // .orderBy('date', descending: true)
              .get();
      // Sort thủ công theo date
      final diaries =
          querySnapshot.docs
              .map((doc) => DiaryModel.fromJson(doc.data(), doc.id))
              .toList();
      diaries.sort((a, b) => b.date.compareTo(a.date));
      return diaries;

      return querySnapshot.docs
          .map((doc) => DiaryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error getting diaries: $e');
      return [];
    }
  }

  // Get diary for specific date
  static Future<DiaryModel?> getDiaryForDate(DateTime date) async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return null;

      // Create date range for the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: userUid)
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThan: Timestamp.fromDate(endOfDay))
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return DiaryModel.fromJson(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      log('Error getting diary for date: $e');
      return null;
    }
  }

  // Upload image to Firebase Storage
  static Future<String?> uploadImage(File imageFile, String diaryId) async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return null;

      final fileName = path.basename(imageFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      final ref = _storage
          .ref()
          .child('diaries')
          .child(userUid)
          .child(diaryId)
          .child(uniqueFileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      log('Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadImages(
    List<File> imageFiles,
    String diaryId,
  ) async {
    final List<String> uploadedUrls = [];

    for (final imageFile in imageFiles) {
      final url = await uploadImage(imageFile, diaryId);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Delete image from Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      log('Error deleting image: $e');
    }
  }

  // Add new diary
  static Future<String?> addDiary(DiaryModel diary) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection(collection)
          .add(diary.toJson());

      return docRef.id;
    } catch (e) {
      log('Error adding diary: $e');
      return null;
    }
  }

  // Update existing diary
  static Future<bool> updateDiary(DiaryModel diary) async {
    try {
      if (diary.id == null) return false;

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(diary.id)
          .update(diary.toJson());

      return true;
    } catch (e) {
      log('Error updating diary: $e');
      return false;
    }
  }

  // Delete diary
  static Future<bool> deleteDiary(String diaryId) async {
    try {
      // First get the diary to delete associated images
      final doc =
          await FirebaseFirestore.instance
              .collection(collection)
              .doc(diaryId)
              .get();

      if (doc.exists) {
        final diary = DiaryModel.fromJson(doc.data()!, doc.id);

        // Delete all images from storage
        for (final imageUrl in diary.imageUrls) {
          await deleteImage(imageUrl);
        }

        // Delete the diary document
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(diaryId)
            .delete();
      }

      return true;
    } catch (e) {
      log('Error deleting diary: $e');
      return false;
    }
  }

  // Save diary (add or update)
  static Future<bool> saveDiary({
    required DateTime date,
    required String content,
    required List<File> imageFiles,
    DiaryModel? existingDiary,
  }) async {
    try {
      final userUid = BaseCommon().userAccount.uid;
      if (userUid == null) return false;

      String diaryId;
      List<String> imageUrls = [];

      if (existingDiary != null) {
        // Update existing diary
        diaryId = existingDiary.id!;
        imageUrls = List.from(existingDiary.imageUrls);
      } else {
        // Create new diary
        final docRef = await FirebaseFirestore.instance
            .collection(collection)
            .add({
              'userId': userUid,
              'date': Timestamp.fromDate(date),
              'content': '',
              'imageUrls': [],
              'createdAt': Timestamp.fromDate(DateTime.now()),
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });
        diaryId = docRef.id;
      }

      // Upload new images
      if (imageFiles.isNotEmpty) {
        final newImageUrls = await uploadImages(imageFiles, diaryId);
        imageUrls.addAll(newImageUrls);
      }

      // Update diary with content and image URLs
      final diary = DiaryModel(
        id: diaryId,
        userId: userUid,
        date: date,
        content: content,
        imageUrls: imageUrls,
        createdAt: existingDiary?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection(collection)
          .doc(diaryId)
          .update(diary.toJson());

      return true;
    } catch (e) {
      log('Error saving diary: $e');
      return false;
    }
  }

  // Remove image from diary
  static Future<bool> removeImageFromDiary(
    String diaryId,
    String imageUrl,
  ) async {
    try {
      // Get current diary
      final doc =
          await FirebaseFirestore.instance
              .collection(collection)
              .doc(diaryId)
              .get();

      if (!doc.exists) return false;

      final diary = DiaryModel.fromJson(doc.data()!, doc.id);

      // Remove image URL from list
      final updatedImageUrls =
          diary.imageUrls.where((url) => url != imageUrl).toList();

      // Delete image from storage
      await deleteImage(imageUrl);

      // Update diary
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(diaryId)
          .update({
            'imageUrls': updatedImageUrls,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });

      return true;
    } catch (e) {
      log('Error removing image from diary: $e');
      return false;
    }
  }
}
