import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_project/resoucre/reponsive_utils.dart';

class CollectionHeightWidget extends StatefulWidget {
  const CollectionHeightWidget({
    super.key,
    required this.getHeight,
    required this.initalizeHeight,
  });
  final Function(double) getHeight;
  final double initalizeHeight;

  @override
  State<CollectionHeightWidget> createState() => _CollectionHeightWidgetState();
}

class _CollectionHeightWidgetState extends State<CollectionHeightWidget> {
  double _height = 0;
  @override
  void initState() {
    _height = widget.initalizeHeight;
    log('initalizeHeight: $_height');
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$_height cm',
          style: TextStyle(
            fontSize: UtilsReponsive.formatFontSize(32, context),
            fontWeight: FontWeight.w500,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.blue.shade100,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18.0),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: Colors.blue,
            inactiveTickMarkColor: Colors.grey,
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Colors.blue,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          child: Slider(
            min: 100,
            max: 220,
            divisions: (220 - 100) ~/ 5, // vạch chia mỗi 5cm
            label: "${_height.toStringAsFixed(0)} cm",
            value: _height,
            onChanged: (value) {
              setState(() {
                _height = value;
                widget.getHeight(_height);
              });
            },
          ),
        ),
      ],
    );
  }
}
