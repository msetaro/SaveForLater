import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:save_for_later/util/database.dart';
import 'package:save_for_later/util/for_later_tile.dart';
import 'package:save_for_later/util/tile_model.dart';

import 'package:flutter/foundation.dart' as foundation;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myBox = Hive.box("mybox");
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _reminderIntController = TextEditingController();
  final TextEditingController _emojiPickerController = TextEditingController();

  Database db = Database();
  String chosenEmoji = "";

  @override
  void initState()
  {
    if(myBox.get("MAINKEY") != null)
    {
      db.loadDataFromStorage();
    }
    super.initState();
  }

  deleteItemFromList(int index)
  {
    setState(() {
      db.storage.removeAt(index);
    });
    db.updateDataAndStore();
  }


  void onCancelPressed()
  {
    _itemNameController.clear();
    _linkController.clear();
    _reminderIntController.clear();
    _emojiPickerController.clear();
    Navigator.of(context).pop();
  }

  void onSavePressed() 
  {
    // add that data to a new ForLaterTile
    setState(() {
          db.storage.add(
          TileModel(
            emoji: _emojiPickerController.text, 
            customName: _itemNameController.text, 
            linkToProduct: _linkController.text, 
            daysTillNotification: int.parse(_reminderIntController.text)
          )
        );
        _itemNameController.clear();
        _linkController.clear();
        _reminderIntController.clear();
    });
    db.updateDataAndStore();
    Navigator.of(context).pop();
  }

  String randEmoji() {
    List emojis = ['🥃', '🥾', '🎸', '🎮', '👠', '👗', '💍', '🛼', '🎟️', '🎧', '🎷', '📱', '💻', '🛍️'];
    var random = Random();
    return emojis[random.nextInt(emojis.length)];
  }

  void createNewItem() {
    _emojiPickerController.text = randEmoji();
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * .70,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  const Text(
                    "Enter a new item",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
            
                  // emoji picker -- need to pick random emoji
                  TextField(
                    controller: _emojiPickerController,
                    style: const TextStyle(fontSize: 50),
                    keyboardType: TextInputType.text,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                    inputFormatters: [FilteringTextInputFormatter.allow(
                      RegExp(
                        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
                         unicode: true)),],
                  ),
            

                  const SizedBox(height: 20),
            
                  // Item name
                  TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Item name"
                    ),
                  ),
            
                  const SizedBox(height: 20),
            
                  // Link
                  TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Link to item"
                    ),
                  ),
            
            
                  const SizedBox(height: 20),
            
                  // Remind in n days
                  TextField(
                    controller: _reminderIntController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Remind me in (days)"
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
            
                  const SizedBox(height: 80),
            
                  // Cancel
                  MaterialButton(
                    onPressed: onCancelPressed,
                    minWidth: 200,
                    height: 50,
                    color: Colors.red,
                    child: const Text("Cancel")
                  ),
            
                  const SizedBox(height: 17),
            
                  // Save
                  MaterialButton(
                    onPressed: onSavePressed,
                    minWidth: 200,
                    height: 50,
                    color: Colors.blue,
                    child: const Text("Save")
                  ),
            
                ]),
            ),
          ),
        );
      }
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createNewItem,
        child: const Icon(Icons.add)),

      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Save For Later",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        elevation: 0,
      ),

      body: Container(
        child: db.storage.isEmpty ? 
        Container(
          padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: 
              const Column(
                children: [
                  Text(
                    "You are not tracking any items, maybe that's a good thing 😅",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),           

                  SizedBox(height: 40),

                  Text(
                    "To add a new item, tap the '+' icon below ⬇️",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),  
                ],
              ),
              )
        : ListView.builder(
          itemCount: db.storage.length,
          itemBuilder: (context, index) {
            return ForLaterTile(
              model: db.storage[index], 
              deleteItem: (context) => deleteItemFromList(index),
            );
          },
      ),
      )
    );
  }
}