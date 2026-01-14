import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class CollectionWeightWidget extends StatefulWidget {
  const CollectionWeightWidget({
    super.key,
    required this.getWeight,
    required this.initalizeWeight,
  });
  final Function(int) getWeight;
  final int initalizeWeight;

  @override
  State<CollectionWeightWidget> createState() => _CollectionWeightWidgetState();
}

class _CollectionWeightWidgetState extends State<CollectionWeightWidget> {
  int _currentKg = 0;
  @override
  void initState() {
    _currentKg = widget.initalizeWeight;
    log('initalizeWeight: $_currentKg');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NumberPicker(
              value: _currentKg,
              minValue: 30,
              maxValue: 150,
              step: 1,
              itemHeight: 80,
              itemWidth: 100,
              axis: Axis.vertical, // có thể đổi thành Axis.horizontal
              selectedTextStyle: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textStyle: const TextStyle(fontSize: 18, color: Colors.grey),
              onChanged:
                  (value) => setState(() {
                    _currentKg = value;
                    widget.getWeight(_currentKg);
                  }),
            ),
            Text(
              'kg',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
