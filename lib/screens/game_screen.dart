import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../controllers/ai_controller.dart';
import '../models/game_manager.dart';
import '../services/audio_service.dart';
import '../widgets/ball.dart';
import '../widgets/paddle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key, this.resetScores = false}) : super(key: key);

  final bool resetScores;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;

  late Paddle _playerPaddle;
  late Paddle _aiPaddle;
  late Ball _ball;
  late AiController _ai;

  // Sizes
  static const double _paddleWidth = 14;
  static const double _paddleHeight = 120;
  static const double _ballRadius = 10;

  bool _isPaused = false;
  // progressive speed multiplier (resets each round)
  double _speedMultiplier = 1.0;
  double _timeSinceMultiplier = 0.0;
  static const double _multiplierInterval = 5.0; // seconds
  static const double _multiplierFactor = 1.1; // 1.1x per interval

  @override
  void initState() {
    super.initState();
    if (widget.resetScores) GameManager.instance.resetScores();

    _playerPaddle = Paddle(width: _paddleWidth, height: _paddleHeight);
    _aiPaddle = Paddle(width: _paddleWidth, height: _paddleHeight);
    _ball = Ball(radius: _ballRadius);
    _ai = AiController(speed: 300);

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration now) {
    if (_lastTick == Duration.zero) _lastTick = now;
    final dt = (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;
    if (_isPaused) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _update(dt);
    });
  }

  void _update(double dt) {
    final size = MediaQuery.of(context).size;
    final areaW = size.width;
    final areaH = size.height - kToolbarHeight;

    // ensure paddles within bounds
    _playerPaddle.clampWithin(areaH);
    _aiPaddle.clampWithin(areaH);

    // AI update
    _aiPaddle.centerY = _ai.update(_aiPaddle.centerY, _ball.y, dt, areaH);

    // progressive speed multiplier: increase every _multiplierInterval
    _timeSinceMultiplier += dt;
    while (_timeSinceMultiplier >= _multiplierInterval) {
      _speedMultiplier *= _multiplierFactor;
      _timeSinceMultiplier -= _multiplierInterval;
    }

    // Ball physics (apply multiplier)
    _ball.update(dt, _speedMultiplier);

    // top/bottom collision
    if (_ball.y - _ball.radius <= 0) {
      _ball.y = _ball.radius;
      _ball.vy = _ball.vy.abs();
    }
    if (_ball.y + _ball.radius >= areaH) {
      _ball.y = areaH - _ball.radius;
      _ball.vy = -_ball.vy.abs();
    }

    // paddle collisions
    // player (left)
    final playerLeft = 0.0;
    final playerRight = playerLeft + _playerPaddle.width;
    if (_ball.x - _ball.radius <= playerRight && _ball.vx < 0) {
      if (_ball.y >= _playerPaddle.top && _ball.y <= _playerPaddle.bottom) {
        _reflectFromPaddle(isLeft: true);
        AudioService.instance.playHit();
      }
    }

    // ai (right)
    final aiRight = areaW;
    final aiLeft = aiRight - _aiPaddle.width;
    if (_ball.x + _ball.radius >= aiLeft && _ball.vx > 0) {
      if (_ball.y >= _aiPaddle.top && _ball.y <= _aiPaddle.bottom) {
        _reflectFromPaddle(isLeft: false);
        AudioService.instance.playHit();
      }
    }

    // scoring
    if (_ball.x + _ball.radius < 0) {
      // ball went past player's paddle -> player loses point
      GameManager.instance.aiScore += 1;
      AudioService.instance.playScore();
      _afterScore(areaW, areaH);
      return;
    }
    if (_ball.x - _ball.radius > areaW) {
      // ball went past AI paddle -> player scores
      GameManager.instance.playerScore += 1;
      AudioService.instance.playScore();
      _afterScore(areaW, areaH);
      return;
    }

    setState(() {});
  }

  void _reflectFromPaddle({required bool isLeft}) {
    final paddle = isLeft ? _playerPaddle : _aiPaddle;
    final relativeIntersect = (_ball.y - paddle.centerY) / (paddle.height / 2);
    final bounceAngle = relativeIntersect * (pi / 3); // 60deg max
    final speed = sqrt(_ball.vx * _ball.vx + _ball.vy * _ball.vy) * 1.02;

    final dir = isLeft ? 1 : -1;
    _ball.vx = dir * speed * cos(bounceAngle).abs();
    _ball.vy = speed * sin(bounceAngle);

    // nudge ball out of paddle to avoid multi-collisions
    if (isLeft)
      _ball.x = paddle.width + _ball.radius + 0.5;
    else
      _ball.x =
          MediaQuery.of(context).size.width - paddle.width - _ball.radius - 0.5;
  }

  void _afterScore(double areaW, double areaH) {
    // check win
    if (GameManager.instance.playerScore >= kWinningScore ||
        GameManager.instance.aiScore >= kWinningScore) {
      final playerWon = GameManager.instance.playerScore >= kWinningScore;
      AudioService.instance.playWin();
      _showGameOver(playerWon);
      return;
    }

    // reset progressive multiplier for next serve/round
    _speedMultiplier = 1.0;
    _timeSinceMultiplier = 0.0;

    // reset ball to center and continue
    _ball.reset(areaW / 2, areaH / 2, toRight: Random().nextBool());
    setState(() {});
  }

  Future<void> _showGameOver(bool playerWon) async {
    _isPaused = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(playerWon ? 'You Win!' : 'You Lose'),
        content: Text(
          playerWon
              ? 'Congratulations — you reached $kWinningScore points.'
              : 'AI reached $kWinningScore points.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              GameManager.instance.resetScores();
              Navigator.of(context).pop();
              _restartRound();
            },
            child: const Text('Restart (reset scores)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isPaused = false;
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _restartRound() {
    final size = MediaQuery.of(context).size;
    final areaH = size.height - kToolbarHeight;
    _playerPaddle.centerY = areaH / 2;
    _aiPaddle.centerY = areaH / 2;
    // reset progressive multiplier when manually restarting
    _speedMultiplier = 1.0;
    _timeSinceMultiplier = 0.0;
    _ball.reset(size.width / 2, areaH / 2, toRight: Random().nextBool());
    _isPaused = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final areaW = size.width;
    final areaH = size.height - kToolbarHeight;

    // initialize positions if zero
    if (_playerPaddle.centerY == 0) _playerPaddle.centerY = areaH / 2;
    if (_aiPaddle.centerY == 0) _aiPaddle.centerY = areaH / 2;
    if (_ball.x == 0 && _ball.y == 0)
      _ball.reset(areaW / 2, areaH / 2, toRight: Random().nextBool());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pong'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                '${GameManager.instance.playerScore} : ${GameManager.instance.aiScore}',
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          // only move player paddle when dragging on left half
          if (details.localPosition.dx <= areaW / 2) {
            _playerPaddle.centerY += details.delta.dy;
            _playerPaddle.clampWithin(areaH);
            setState(() {});
          }
        },
        onTapDown: (details) {
          // quick tap to move player paddle center
          if (details.localPosition.dx <= areaW / 2) {
            _playerPaddle.centerY = details.localPosition.dy;
            _playerPaddle.clampWithin(areaH);
            setState(() {});
          }
        },
        child: Stack(
          children: [
            // Player paddle - left
            Positioned(
              left: 0,
              top: _playerPaddle.top,
              width: _playerPaddle.width,
              height: _playerPaddle.height,
              child: Container(color: const Color.fromARGB(255, 202, 68, 68)),
            ),
            // AI paddle - right
            Positioned(
              left: areaW - _aiPaddle.width,
              top: _aiPaddle.top,
              width: _aiPaddle.width,
              height: _aiPaddle.height,
              child: Container(color: const Color.fromARGB(255, 126, 73, 73)),
            ),
            // Ball
            Positioned(
              left: _ball.x - _ball.radius,
              top: _ball.y - _ball.radius,
              width: _ball.radius * 2,
              height: _ball.radius * 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // UI controls
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _restartRound();
                    },
                    child: const Text('Restart Round'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      GameManager.instance.resetScores();
                      _restartRound();
                    },
                    child: const Text('Restart Game (reset scores)'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Menu'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
