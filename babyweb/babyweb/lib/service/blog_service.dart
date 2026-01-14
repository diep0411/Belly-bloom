import 'package:babyweb/model/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogService {
  static String blogCollection = 'blogs';
  static Future<bool> addBlog(BlogModel blog) async {
   try {
      await FirebaseFirestore.instance.collection(blogCollection).add(blog.toJson());
      return true;
   } catch (e) {
     return false;
   }
  }
  static Future<bool> updateBlog(BlogModel blog) async {
    try {
      await FirebaseFirestore.instance.collection(blogCollection).doc(blog.id).update(blog.toJson());
      return true;
    } catch (e) {
      return false;
    }
  
  }
  static Future<List<BlogModel>> loadBlog() async {
    final snapshot = await FirebaseFirestore.instance.collection(blogCollection).get();
    return snapshot.docs.map((doc) => BlogModel.fromJson(doc.data(), doc.id)).toList();
  }
}