import 'package:hive_flutter/hive_flutter.dart';
import 'package:save_for_later/util/tile_model.dart';

class Database {

  List storage = [];
  // our hive box
  final _myBox = Hive.box('mybox');

  // gives us some dummy data
  void createInitialData()
  {
    storage = [
      TileModel(emoji: '🥾', customName: "Boots", linkToProduct: "google.com", daysTillNotification: 30),
      TileModel(emoji: '🥃', customName: "Whiskey", linkToProduct: "google.com", daysTillNotification: 20)
    ];
  }

  void loadDataFromStorage()
  {
    storage = _myBox.get("MAINKEY");
  }

  void updateDataAndStore()
  {
    _myBox.put("MAINKEY", storage);
  }
}