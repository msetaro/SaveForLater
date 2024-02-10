import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spendshield/util/database.dart';
import 'package:spendshield/util/for_later_tile.dart';
import 'package:spendshield/util/tile_model.dart';

import 'package:flutter/foundation.dart' as foundation;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final myBox = Hive.box("mybox");
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _reminderIntController = TextEditingController();
  final TextEditingController _emojiPickerController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Database db = Database();
  String chosenEmoji = "";


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) 
  {
    // This method is called when the app lifecycle state changes
    if (state == AppLifecycleState.resumed) {
      // update all timestamps on displayed cards
      for(TileModel card in db.storage)
      {
        int diffDays = card.notificationDate.difference(DateTime.now()).inDays + 1;
        
        int toSubtract = diffDays - card.daysTillNotification;

        setState(() {
          card.daysTillNotification -= toSubtract;
        });

        // save to db
        db.updateDataAndStore();
      }
    }
  }

  @override
  void initState()
  {
    if(myBox.get("MAINKEY") != null)
    {
      db.loadDataFromStorage();
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  deleteItemFromList(int index)
  {
    AwesomeNotifications().cancel(db.storage.elementAt(index).id);
    
    setState(() {
      db.storage.removeAt(index);
      db.storage.sort((a, b) => a.daysTillNotification.compareTo(b.daysTillNotification));
    });

    db.updateDataAndStore();
  }

  void onCancelPressed()
  {
    Navigator.of(context).pop();
    _itemNameController.clear();
    _linkController.clear();
    _reminderIntController.clear();
    _emojiPickerController.clear();
  }

  void onSavePressed(bool updateItem, int index) 
  {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if(updateItem)
    {
      // delete existing item
      deleteItemFromList(index);
    }

    //add https if its not there
    var finalUrl = _linkController.text;
    if(!finalUrl.contains('https://') && !finalUrl.contains('http://'))
    {
      finalUrl = "https://${_linkController.text}";
    }

    var toSave = TileModel(
        emoji: _emojiPickerController.text, 
        customName: _itemNameController.text, 
        linkToProduct: finalUrl, 
        inputNotificationDate: int.parse(_reminderIntController.text),
        daysTillNotification: int.parse(_reminderIntController.text),
        creationTime: DateTime.now(),
        notificationDate: DateTime.now().add(Duration(days: int.parse(_reminderIntController.text)))
      );

    // schedule notification
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: toSave.id, 
        channelKey: "main_channel",
        title: "Still interested in buying ${_itemNameController.text} ${_emojiPickerController.text}?",
      ),
      schedule: NotificationCalendar.fromDate(date: DateTime.now().add(Duration(days: int.parse(_reminderIntController.text))))
    );

    // add that data to a new ForLaterTile
    setState(() {
        if(updateItem)
        {
          db.storage.insert(index, toSave);
        }
        else
        {
          db.storage.add(toSave);
        }
        db.storage.sort((a, b) => a.daysTillNotification.compareTo(b.daysTillNotification));
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

  void showCrudPopup(bool updateItem, [int index = 0]) {
  
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  const Text(
                    "Enter a new item",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
            
                  Form(
                    key: _formKey,
                    child: Column(children: [                  // emoji picker -- need to pick random emoji
                  TextFormField(
                    controller: _emojiPickerController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required and only accepts emojis.';
                      }
                      return null;
                    },
                    style: const TextStyle(fontSize: 50),
                    keyboardType: TextInputType.text,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none, 
                      labelText: "Tap to change emoji",
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      alignLabelWithHint: true
                    ),
                    inputFormatters: [FilteringTextInputFormatter.allow(
                      RegExp(
                        r'[\u{1F000}-\u{1F9EF}\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
                         unicode: true)),],
                  ),
            

                  const SizedBox(height: 20),
            
                  // Item name
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                    },
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Item name"
                    ),
                  ),
            
                  const SizedBox(height: 20),
            
                  // Link
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                    },
                    controller: _linkController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Link to item"
                    ),
                  ),
            
            
                  const SizedBox(height: 20),
            
                  // Remind in n days
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required.';
                      }
                    },
                    controller: _reminderIntController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Remind me in (days)"
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),],)),
            
                  const SizedBox(height: 20),
            
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
                    onPressed: () => onSavePressed(updateItem, index),
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
  
  void createNewItem() {
    _emojiPickerController.text = randEmoji();
    showCrudPopup(false);
  } 

  void updateItem(int index) async {

    if(db.storage[index].daysTillNotification < 1)
    {
      try {
        // open link instead
        Uri url = Uri.parse(db.storage[index].linkToProduct);
        var res = await launchUrl(url);

        if(!res){ throw Exception(); }
      } 
      on Exception catch(_)
      {
        // show alert to user
        showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Sorry! There was an error opening the URL 😅'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              }
            );
      }
    }
    else 
    {
      _emojiPickerController.text = db.storage[index].emoji;
      _itemNameController.text = db.storage[index].customName;
      _linkController.text = db.storage[index].linkToProduct;
      _reminderIntController.text = db.storage[index].daysTillNotification.toString();

      showCrudPopup(true, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createNewItem,
        child: const Icon(Icons.notification_add)),

      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 20, 11),
        title: const Text("⏰ Your reminders 💸",
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
                    "To add a new item, tap the button below ⬇️",
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
              updateItem: () => updateItem(index),
            );
          },
      ),
      )
    );
  }
}