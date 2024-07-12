
import 'package:flutter/material.dart';

class CustomZoomButton extends StatelessWidget {
  final void Function() onTap;
  final bool isZoomIn;

  const CustomZoomButton({
    super.key,
    required this.onTap,
    required this.isZoomIn,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      onPressed: onTap,
      child: Icon(
        isZoomIn ? Icons.add : Icons.remove,
      ),
    );
  }
}
