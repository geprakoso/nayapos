import 'package:flutter/material.dart';

/// A widget that looks like a thermal printer receipt with zig-zag edges
/// at the top and bottom.
class ThermalReceiptCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double width;

  const ThermalReceiptCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.width = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: ZigZagEdgePainter(color: Theme.of(context).colorScheme.surface),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Paints a zig-zag (serrated) edge on the top and bottom of the canvas
/// to simulate torn receipt paper, by cutting out triangles using the 
/// background color.
class ZigZagEdgePainter extends CustomPainter {
  final Color color;
  final double zigZagWidth;
  final double zigZagHeight;

  ZigZagEdgePainter({
    required this.color,
    this.zigZagWidth = 8.0,
    this.zigZagHeight = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw top zigzags
    Path topPath = Path();
    topPath.moveTo(0, 0);
    for (double x = 0; x < size.width; x += zigZagWidth) {
      topPath.lineTo(x + zigZagWidth / 2, zigZagHeight);
      topPath.lineTo(x + zigZagWidth, 0);
    }
    topPath.lineTo(size.width, 0);
    topPath.lineTo(0, 0);
    topPath.close();

    canvas.drawPath(topPath, paint);

    // Draw bottom zigzags
    Path bottomPath = Path();
    bottomPath.moveTo(0, size.height);
    for (double x = 0; x < size.width; x += zigZagWidth) {
      bottomPath.lineTo(x + zigZagWidth / 2, size.height - zigZagHeight);
      bottomPath.lineTo(x + zigZagWidth, size.height);
    }
    bottomPath.lineTo(size.width, size.height);
    bottomPath.lineTo(0, size.height);
    bottomPath.close();

    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
