class AiController {
  AiController({this.speed = 250});

  final double speed; // pixels per second maximum movement

  double update(
    double aiCenterY,
    double ballY,
    double dt,
    double areaHeight, {
    double speedMultiplier = 1.0,
  }) {
    final dy = ballY - aiCenterY;
    final maxMove = speed * speedMultiplier / 2 * dt;
    final move = dy.clamp(-maxMove, maxMove);
    var next = aiCenterY + move;
    // constrain within screen
    next = next.clamp(0.0, areaHeight);
    return next;
  }
}
