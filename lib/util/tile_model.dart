import 'dart:math';

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

  @HiveField(4)
  final int id = Random().nextInt(99999999);

  TileModel({
    required this.emoji,
    required this.customName,
    required this.linkToProduct,
    required this.daysTillNotification,
  });
}