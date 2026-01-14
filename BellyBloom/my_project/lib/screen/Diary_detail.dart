import 'package:flutter/material.dart';
import 'package:my_project/resoucre/image_manager.dart';
import 'package:my_project/model/diary.dart';

class MyDiaryPage extends StatefulWidget {
  const MyDiaryPage({super.key, required this.diary});
  final Diary diary;

  @override
  State<MyDiaryPage> createState() => _MyDiaryPageState();
}

class _MyDiaryPageState extends State<MyDiaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Sửa',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Xóa',
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.diary.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.diary.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              Center(
                child: Image.asset(ImageRes.welcome1, height: 300, width: 300),
              ),
              Text(
                'The forest was alive with secrets. Each rustling leaf carried a story, each beam of sunlight danced with mystery. Deep within, a small fox with golden fur paused by a stream, its reflection shimmering like a dream. It wasn’t just water—it was a portal, a gateway to a world where time flowed backward and stars whispered their ancient songs. The fox hesitated, then leapt, vanishing into the ripples, leaving only the echo of its courage behind.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
