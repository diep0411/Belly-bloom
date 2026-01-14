import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/blog_model.dart';

class BlogService {
  static const String collection = 'blogs';

  // Load all blogs
  static Future<List<BlogModel>> loadBlogs() async {
    try {
      QuerySnapshot snapshot;
      
      // Try to order by createdAt if field exists
      try {
        snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If createdAt field doesn't exist, load without ordering
        log('createdAt field not found, loading without order: $e');
        snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .get();
      }

      final blogs = snapshot.docs
          .map((doc) {
            try {
              return BlogModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              log('Error parsing blog ${doc.id}: $e');
              return null;
            }
          })
          .where((blog) => blog != null)
          .cast<BlogModel>()
          .toList();

      // Sort manually if createdAt exists
      blogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return blogs;
    } catch (e) {
      log('Error loading blogs: $e');
      return [];
    }
  }

  // Load blogs for specific week
  static Future<List<BlogModel>> loadBlogsForWeek(int weekNumber) async {
    try {
      final allBlogs = await loadBlogs();
      return allBlogs.where((blog) => blog.isForWeek(weekNumber)).toList();
    } catch (e) {
      log('Error loading blogs for week: $e');
      return [];
    }
  }

  // Search blogs
  static Future<List<BlogModel>> searchBlogs(String query) async {
    try {
      final allBlogs = await loadBlogs();
      return allBlogs.where((blog) {
        return blog.title.toLowerCase().contains(query.toLowerCase()) ||
            blog.subtitle.toLowerCase().contains(query.toLowerCase()) ||
            blog.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      log('Error searching blogs: $e');
      return [];
    }
  }
}
