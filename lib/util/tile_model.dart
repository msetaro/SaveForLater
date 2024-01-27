import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';

part 'tile_model.g.dart';

@HiveType(typeId: 0)
class TileModel extends HiveObject {
  @HiveField(0)
  final String emoji;

  @HiveField(1)
  final String customName;

  @HiveField(2)
  final String linkToProduct;

  @HiveField(3)
  final int inputNotificationDate;

  int _daysTillNotification; // Remove 'final'

  @HiveField(4)
  int get daysTillNotification => _daysTillNotification; // Getter

  @HiveField(5)
  final int id = Random().nextInt(99999999);

  @HiveField(6)
  final DateTime creationTime;

  TileModel({
    required this.emoji,
    required this.customName,
    required this.linkToProduct,
    required this.inputNotificationDate,
    required int daysTillNotification, // Update the parameter
    required this.creationTime,
  }) : _daysTillNotification = daysTillNotification; // Initialize the field in the constructor

  // Setter for daysTillNotification
  set daysTillNotification(int value) {
    _daysTillNotification = value;
  }
}
