class Paddle {
  Paddle({required this.width, required this.height});

  final double width;
  final double height;
  double centerY = 0.0;

  double get top => centerY - height / 2;
  double get bottom => centerY + height / 2;

  void clampWithin(double areaHeight) {
    if (top < 0) centerY = height / 2;
    if (bottom > areaHeight) centerY = areaHeight - height / 2;
  }
}
