import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class CollectioncalenderWidget extends StatefulWidget {
  const CollectioncalenderWidget({
    super.key,
    required this.calculateDueDate,
    required this.inteializeWeek,
    required this.getWeek,
  });
  final Function(DateTime, int) calculateDueDate;
  final int inteializeWeek;
  final Function(int) getWeek;
  @override
  State<CollectioncalenderWidget> createState() =>
      _CollectioncalenderWidgetState();
}

class _CollectioncalenderWidgetState extends State<CollectioncalenderWidget> {
  int _currentWeek = 0;
  @override
  void initState() {
    _currentWeek = widget.inteializeWeek;
    log('initalizeWeek: $_currentWeek');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Ngày dự sinh của bạn là: ${DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: _currentWeek * 7)))}',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tuan thu',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            NumberPicker(
              value: _currentWeek,
              minValue: 1,
              maxValue: 40,
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
                    _currentWeek = value;
                    widget.getWeek(_currentWeek);
                    widget.calculateDueDate(DateTime.now(), _currentWeek);
                  }),
            ),
          ],
        ),
      ],
    );
  }
}
