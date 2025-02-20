import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Color> gradientColors;

  const GradientAppBar({
    super.key,
    required this.title,
    this.gradientColors = const [
      Color(0xFF900C0C),
      Color(0xFFd40101),
      Color(0xFFff5a5a),
    ],
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the brightness of the background
    Color dominantColor = gradientColors[0];
    double brightness = (dominantColor.red * 299 +
            dominantColor.green * 587 +
            dominantColor.blue * 114) /
        1000;

    // Choose text color based on background brightness
    Color textColor = brightness > 128 ? Colors.black87 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
