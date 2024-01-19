import 'package:hive_flutter/hive_flutter.dart';

part "tile_model.g.dart";

@HiveType(typeId: 0)
class TileModel extends HiveObject {

  @HiveField(0)
  final String emoji;

  @HiveField(1)
  final String customName;

  @HiveField(2)
  final String linkToProduct;

  @HiveField(3)
  final int daysTillNotification;

  TileModel({
    required this.emoji,
    required this.customName,
    required this.linkToProduct,
    required this.daysTillNotification,
  });
}