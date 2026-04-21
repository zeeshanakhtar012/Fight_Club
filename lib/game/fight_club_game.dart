import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class FightClubGame extends FlameGame with HasCollisionDetection {
  late RobotFighter player;
  late RobotFighter opponent;

  @override
  Future<void> onLoad() async {
    // Add background
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF0D0D0D),
      ),
    );

    // Add ground with glow - MOVED HIGHER to prevent overlap
    double groundHeight = 230;
    add(
      RectangleComponent(
        position: Vector2(0, size.y - groundHeight),
        size: Vector2(size.x, 5),
        paint: Paint()..color = Colors.red.withOpacity(0.8),
      ),
    );
    add(
      RectangleComponent(
        position: Vector2(0, size.y - groundHeight + 5),
        size: Vector2(size.x, groundHeight - 5),
        paint: Paint()..color = Colors.red.withOpacity(0.1),
      ),
    );

    // Initialize fighters based on archetypes
    final playerStats = GameController.instance.selectedCharacter.value;

    player =
        RobotFighter(
            isPlayer: true,
            color: Colors.blueAccent,
            bulk: playerStats.name == 'Tank Fighter'
                ? 1.4
                : (playerStats.name == 'Speed Fighter' ? 0.8 : 1.0),
          )
          ..position = Vector2(100, size.y - groundHeight - 100)
          ..size = Vector2(60, 100);

    opponent =
        RobotFighter(
            isPlayer: false,
            color: Colors.redAccent,
            bulk: 1.1, // AI is slightly bulky for boss feel
          )
          ..position = Vector2(size.x - 160, size.y - groundHeight - 100)
          ..size = Vector2(60, 100);

    add(player);
    add(opponent);
  }

  void movePlayer(double direction) => player.walkDirection = direction;
  void stopPlayer() => player.walkDirection = 0;
  void playerAttack() => player.performAttack();
  void playerBlock(bool blocking) => player.isBlocking = blocking;

  void jumpPlayer() => player.jump();
  void playerKick() => player.performKick();

  double _totalTime = 0;
  double elapsedTime() => _totalTime;

  @override
  void update(double dt) {
    super.update(dt);
    _totalTime += dt;
  }

  void shakeCamera() {
    // Correct way to shake camera in Flame 1.x: add a MoveEffect to the viewfinder
    camera.viewfinder.add(
      MoveEffect.by(Vector2(4, 4), ZigzagEffectController(period: 0.1)),
    );
  }
}

class RobotFighter extends PositionComponent
    with CollisionCallbacks, HasGameRef<FightClubGame> {
  final bool isPlayer;
  final Color color;
  final double bulk;

  double walkDirection = 0;
  double speed = 210;
  bool isBlocking = false;
  bool isAttacking = false;
  bool isKicking = false;
  double attackProgress = 0;
  double kickProgress = 0;
  double walkCycle = 0;
  double hitFlashTimer = 0;
  double health = 100;

  // Physics
  double yVelocity = 0;
  static const double gravity = 900;
  static const double jumpForce = -450;
  late double groundY;

  // AI Specifics
  String aiState = "Idle"; // Approaching, Spacing, Retreating
  double aiActionTimer = 0;
  double targetDistance = 60.0;

  int facingDirection = 1; // 1 for Right, -1 for Left

  RobotFighter({required this.isPlayer, required this.color, this.bulk = 1.0});

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    health = isPlayer
        ? GameController.instance.selectedCharacter.value.health
        : 100.0;
    targetDistance = isPlayer
        ? 60.0
        : (bulk > 1.2 ? 40.0 : 70.0); // Tank AI stays closer
    groundY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Facing logic
    RobotFighter target = isPlayer ? gameRef.opponent : gameRef.player;
    facingDirection = target.position.x > position.x ? 1 : -1;

    if (hitFlashTimer > 0) {
      hitFlashTimer -= dt;
    }

    // Jump Physics
    if (position.y < groundY || yVelocity != 0) {
      yVelocity += gravity * dt;
      position.y += yVelocity * dt;

      if (position.y >= groundY) {
        position.y = groundY;
        yVelocity = 0;
      }
    }

    if (!isPlayer) {
      _updateAI(dt);
    } else {
      // Player Movement
      position.x += walkDirection * speed * dt;
      position.x = position.x.clamp(0.0, gameRef.size.x - size.x);

      if (walkDirection != 0) {
        walkCycle += dt * 12;
      } else {
        walkCycle = (walkCycle % (2 * pi)) * 0.9; // Smooth stop
      }
    }

    // Animations
    if (isAttacking) {
      attackProgress += dt * 6;
      if (attackProgress >= 1.0) {
        isAttacking = false;
        attackProgress = 0;
      }
    }
    if (isKicking) {
      kickProgress += dt * 5;
      if (kickProgress >= 1.0) {
        isKicking = false;
        kickProgress = 0;
      }
    }

    // Stamina Regen
    if (isPlayer && !isAttacking && !isKicking && !isBlocking) {
      double regenRate = 12.0;
      double newStamina =
          GameController.instance.currentStamina.value + (regenRate * dt);
      GameController.instance.currentStamina.value = newStamina.clamp(
        0.0,
        100.0,
      );
    }
  }

  void jump() {
    if (position.y >= groundY) {
      yVelocity = jumpForce;
    }
  }

  void _updateAI(double dt) {
    aiActionTimer -= dt;
    double playerX = gameRef.player.position.x;
    double dist = (position.x - playerX).abs() - 40; // effective gap

    // AI State Machine
    if (aiActionTimer <= 0) {
      if (dist > targetDistance + 30) {
        aiState = "Approaching";
        aiActionTimer = 0.5 + Random().nextDouble();
      } else if (dist < targetDistance - 30) {
        aiState = "Retreating";
        aiActionTimer = 0.3 + Random().nextDouble();
      } else {
        aiState = "Spacing";
        aiActionTimer = 0.4 + Random().nextDouble();
      }

      // Randomly Jump
      if (Random().nextDouble() < 0.2 && position.y >= groundY) {
        jump();
      }
    }

    // Exec Movement
    if (aiState == "Approaching") {
      walkDirection = position.x > playerX ? -1 : 1;
    } else if (aiState == "Retreating") {
      walkDirection = position.x > playerX ? 1 : -1;
    } else {
      walkDirection = sin(gameRef.elapsedTime() * 10) > 0 ? 0.3 : -0.3;
    }

    position.x += walkDirection * (speed * 0.8) * dt;
    position.x = position.x.clamp(0.0, gameRef.size.x - size.x);
    walkCycle += dt * 10;

    // Smart Attack Logic (Punch or Kick)
    if (dist < 80 &&
        !isAttacking &&
        !isKicking &&
        Random().nextDouble() < 0.025) {
      if (Random().nextDouble() < 0.7) {
        performAttack();
      } else {
        performKick();
      }
    }
  }

  void performAttack() {
    if (isAttacking ||
        isKicking ||
        (isPlayer && GameController.instance.currentStamina.value < 15))
      return;

    if (isPlayer) {
      GameController.instance.currentStamina.value -= 15;
      GameController.instance.totalAttempts.value++;
    }

    isAttacking = true;
    attackProgress = 0;

    _checkHit(
      range: 85,
      damage: isPlayer
          ? GameController.instance.selectedCharacter.value.strength
          : (bulk * 10),
    );
  }

  void performKick() {
    if (isAttacking ||
        isKicking ||
        (isPlayer && GameController.instance.currentStamina.value < 25))
      return;

    if (isPlayer) {
      GameController.instance.currentStamina.value -= 25;
      GameController.instance.totalAttempts.value++;
    }

    isKicking = true;
    kickProgress = 0;

    _checkHit(
      range: 100,
      damage: isPlayer
          ? (GameController.instance.selectedCharacter.value.strength * 1.5)
          : (bulk * 15),
      delayMs: 150,
    );
  }

  void _checkHit({
    required double range,
    required double damage,
    int delayMs = 80,
  }) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      RobotFighter target = isPlayer ? gameRef.opponent : gameRef.player;
      double dist = (target.position.x - position.x).abs();
      // Also check vertical distance
      double yDist = (target.position.y - position.y).abs();

      if (dist < range && yDist < 50) {
        target.takeDamage(damage);
        if (isPlayer) GameController.instance.totalHits.value++;
        gameRef.add(
          ClashSpark(
            position: (position + target.position) / 2 + Vector2(30, 40),
          ),
        );
      }
    });
  }

  void takeDamage(double damage) {
    if (isBlocking) damage *= 0.25;

    health -= damage;
    hitFlashTimer = 0.2;
    gameRef.shakeCamera();

    if (isPlayer) {
      GameController.instance.updateStats(playerHealth: health);
    } else {
      GameController.instance.updateStats(opponentHealthVal: health);
    }

    // Knockback away from opponent
    RobotFighter target = isPlayer ? gameRef.opponent : gameRef.player;
    double kbDir = position.x > target.position.x ? 1 : -1;
    position.x += kbDir * (20 / bulk);
  }

  @override
  void render(Canvas canvas) {
    // Safety check for size
    if (size.x <= 0 || size.y <= 0) return;

    final paint = Paint()
      ..color = hitFlashTimer > 0 ? Colors.white : color
      ..style = PaintingStyle.fill;

    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Flip the canvas if facing left
    canvas.save();
    if (facingDirection == -1) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    double centerX = size.x / 2;
    double bodyWidth = 42 * bulk;
    double headSize = 22;

    // 1. Legs with Joints
    double legOffset = sin(walkCycle) * 18;
    // Kick leg animation
    double kickLegSwing = isKicking ? (sin(kickProgress * pi) * 60) : 0;

    void drawLeg(double xPos, bool isRightLeg) {
      double currentLegOffset = isRightLeg ? legOffset : -legOffset;
      canvas.save();
      if (isRightLeg && isKicking) {
        canvas.translate(xPos + 6, 70);
        canvas.rotate(-kickLegSwing * pi / 180);
        canvas.translate(-(xPos + 6), -70);
      }

      // Thigh
      canvas.drawRect(Rect.fromLTWH(xPos, 70, 12, 15), paint);
      // Knee joint
      canvas.drawCircle(Offset(xPos + 6, 85), 4, detailPaint);
      // Shin
      canvas.drawRect(
        Rect.fromLTWH(
          xPos,
          85 + (isKicking ? 0 : currentLegOffset.clamp(0, 5)),
          12,
          20,
        ),
        paint,
      );
      canvas.restore();
    }

    drawLeg(centerX - 18, false);
    drawLeg(centerX + 6, true);

    // 2. Torso with Energy Core
    final torsoRect = Rect.fromCenter(
      center: Offset(centerX, 45),
      width: bodyWidth,
      height: 55,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(10)),
      paint,
    );

    // Armor Plating lines
    canvas.drawPath(
      Path()
        ..moveTo(centerX - bodyWidth / 2 + 5, 30)
        ..lineTo(centerX + bodyWidth / 2 - 5, 30)
        ..moveTo(centerX - bodyWidth / 2 + 5, 55)
        ..lineTo(centerX + bodyWidth / 2 - 5, 55),
      detailPaint,
    );

    // Energy Core Glow
    double corePulse = (sin(gameRef.elapsedTime() * 5) + 1) / 2;
    canvas.drawCircle(
      Offset(centerX, 45),
      (8 + (corePulse * 4)).clamp(1, 20),
      Paint()
        ..color = (isPlayer ? Colors.cyanAccent : Colors.orangeAccent)
            .withOpacity(0.5 + corePulse * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 3. Head & Visor
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, 8),
          width: headSize,
          height: headSize,
        ),
        const Radius.circular(5),
      ),
      paint,
    );
    // Glowing Visor
    double visorGlow = (isAttacking || isKicking) ? 1.0 : 0.6;
    canvas.drawRect(
      Rect.fromLTWH(centerX - headSize / 2 + 3, 4, headSize - 6, 5),
      Paint()
        ..color = (hitFlashTimer > 0 ? Colors.red : Colors.white).withOpacity(
          visorGlow,
        )
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (isAttacking || isKicking) ? 3 : 0,
        ),
    );

    // 4. Arms
    double punchSweep = isAttacking
        ? (sin(attackProgress * pi) * 45)
        : (sin(walkCycle * 0.8) * 8);

    // Shoulders
    canvas.drawCircle(Offset(centerX - bodyWidth / 2, 35), 6, paint);
    canvas.drawCircle(Offset(centerX + bodyWidth / 2, 35), 6, paint);

    // Front Arm (Punching)
    if (isAttacking) {
      canvas.drawRect(
        Rect.fromLTWH(centerX + bodyWidth / 2, 32, 25 + punchSweep, 14),
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + bodyWidth / 2 + 25 + punchSweep, 39),
        10,
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(centerX + bodyWidth / 2, 35 + punchSweep, 12, 35),
        paint,
      );
    }

    if (isBlocking) {
      final shieldRect = Rect.fromLTWH(centerX + 25, 10, 20, 70);
      final shieldPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.cyan.withOpacity(0.6)],
        ).createShader(shieldRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shieldRect, const Radius.circular(5)),
        shieldPaint,
      );
    }

    canvas.restore();
  }
}

class ClashSpark extends PositionComponent with HasGameRef {
  double timer = 0.3;
  ClashSpark({required Vector2 position}) : super(position: position);

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity((timer / 0.3).clamp(0.0, 1.0));
    for (int i = 0; i < 5; i++) {
      double angle = (i * 72) * pi / 180;
      canvas.drawLine(
        Offset(cos(angle) * 5, sin(angle) * 5),
        Offset(cos(angle) * 20, sin(angle) * 20),
        paint..strokeWidth = 2,
      );
    }
  }

  @override
  void update(double dt) {
    timer -= dt;
    if (timer <= 0) removeFromParent();
  }
}
