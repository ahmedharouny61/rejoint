import 'package:flutter/material.dart';

class GradiantContainer extends StatelessWidget {
  const GradiantContainer(
      {super.key, required this.cooler, required this.widget});
  final List<Color> cooler;
  final Widget widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cooler,
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: widget),
    );
  }
}
