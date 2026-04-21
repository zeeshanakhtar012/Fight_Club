import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class FightClubGame extends FlameGame with HasCollisionDetection {
  late FighterPlayer player;
  late FighterAI opponent;

  @override
  Future<void> onLoad() async {
    // Add background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1A1A1A),
    ));

    // Add ground
    add(RectangleComponent(
      position: Vector2(0, size.y - 50),
      size: Vector2(size.x, 50),
      paint: Paint()..color = Colors.red.withOpacity(0.3),
    ));

    // Initialize fighters
    player = FighterPlayer()
      ..position = Vector2(100, size.y - 150)
      ..size = Vector2(60, 100);
    
    opponent = FighterAI()
      ..position = Vector2(size.x - 160, size.y - 150)
      ..size = Vector2(60, 100);

    add(player);
    add(opponent);
  }

  void movePlayer(double direction) => player.direction = direction;
  void stopPlayer() => player.direction = 0;
  void playerAttack() => player.attack();
  void playerBlock(bool blocking) => player.isBlocking = blocking;
}

class FighterPlayer extends RectangleComponent with CollisionCallbacks {
  double direction = 0;
  double speed = 200;
  bool isBlocking = false;
  bool isAttacking = false;
  double attackCooldown = 0;

  FighterPlayer() : super(paint: Paint()..color = Colors.blue);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    // Movement
    position.x += direction * speed * dt;
    position.x = position.x.clamp(0.0, (parent as FightClubGame).size.x - size.x);

    // Attack handling
    if (attackCooldown > 0) {
      attackCooldown -= dt;
      if (attackCooldown <= 0) {
        isAttacking = false;
        paint.color = Colors.blue; 
      }
    }

    // Stamina Regeneration (5 per second)
    if (!isAttacking && !isBlocking) {
      double newStamina = GameController.instance.currentStamina.value + (5 * dt);
      GameController.instance.currentStamina.value = newStamina.clamp(0.0, 100.0);
    }
  }

  void attack() {
    if (attackCooldown > 0 || GameController.instance.currentStamina.value < 10) return;

    GameController.instance.currentStamina.value -= 10;
    GameController.instance.totalAttempts.value++;
    isAttacking = true;
    attackCooldown = 0.5;
    paint.color = Colors.yellow; // Visual indicator for attack

    // Check hit manually for simplicity or use collision callbacks
    // For this prototype, if close enough to opponent when attacking
    final game = parent as FightClubGame;
    if ((game.opponent.position.x - (position.x + size.x)).abs() < 50) {
      game.opponent.takeDamage(GameController.instance.selectedCharacter.value.strength);
      GameController.instance.totalHits.value++;
    }
  }
}

class FighterAI extends RectangleComponent with CollisionCallbacks {
  double health = 100;
  double aiTimer = 0;
  Random rng = Random();

  FighterAI() : super(paint: Paint()..color = Colors.red);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    aiTimer += dt;
    // Simple AI: Move towards player, attack occasionally
    final game = parent as FightClubGame;
    double dist = position.x - (game.player.position.x + game.player.size.x);

    if (dist > 40) {
      position.x -= 100 * dt; // Move left
    } else if (dist < 20) {
      position.x += 100 * dt; // Move right
    }

    if (aiTimer > 2.0) {
      aiTimer = 0;
      if (dist < 60 && !game.player.isBlocking) {
        // AI Attack
        paint.color = Colors.orange;
        Future.delayed(const Duration(milliseconds: 300), () {
          if (dist < 60) {
            double damage = 10.0;
            if (game.player.isBlocking) damage *= 0.5;
            GameController.instance.updateStats(
              playerHealth: GameController.instance.currentHealth.value - damage,
            );
          }
          paint.color = Colors.red;
        });
      }
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    GameController.instance.updateStats(opponentHealthVal: health);
    // Visual flash
    paint.color = Colors.white;
    Future.delayed(const Duration(milliseconds: 100), () => paint.color = Colors.red);
  }
}
