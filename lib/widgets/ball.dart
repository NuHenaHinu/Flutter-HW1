import 'dart:math';

class Ball {
  Ball({required this.radius});

  final double radius;
  double x = 0.0;
  double y = 0.0;
  double vx = 200.0; // pixels/s
  double vy = 150.0;

  void reset(double centerX, double centerY, {bool toRight = true}) {
    x = centerX;
    y = centerY;
    final rnd = Random();
    final speed = 220.0 + rnd.nextDouble() * 80.0;
    final angle = (rnd.nextDouble() * 0.6 - 0.3); // small angle variation
    vx = (toRight ? 1 : -1) * speed * cos(angle).abs();
    vy = speed * sin(angle);
  }

  void update(double dt, [double multiplier = 1.0]) {
    x += vx * dt * multiplier;
    y += vy * dt * multiplier;
  }
}
