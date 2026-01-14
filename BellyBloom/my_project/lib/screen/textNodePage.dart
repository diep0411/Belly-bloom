import 'package:flutter/material.dart';

class TextNodePage extends StatefulWidget {
  const TextNodePage({super.key});

  @override
  State<TextNodePage> createState() => _TextNodePageState();
}

class _TextNodePageState extends State<TextNodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Text Node Page')),
      body: Center(child: Text('This is the Text Node Page')),
    );
  }
}