import 'package:flutter/material.dart';
import 'package:my_project/model/hand_book.dart';

class HandbookDetailPage extends StatefulWidget {
  const HandbookDetailPage({super.key, required this.handBook});
  final HandBook handBook;

  @override
  State<HandbookDetailPage> createState() => _HandbookDetailPageState();
}

class _HandbookDetailPageState extends State<HandbookDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Hand Book')),
      body: const Center(child: Text('HandBook')),
    );
  }
}
