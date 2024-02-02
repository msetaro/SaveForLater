import "package:flutter/material.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:spendshield/util/tile_model.dart";

@HiveType(typeId: 0)
class ForLaterTile extends StatelessWidget {

  TileModel model;
  Function(BuildContext?) deleteItem;
  void Function() updateItem;

  ForLaterTile({
    super.key,
    required this.model,
    required this.deleteItem,
    required this.updateItem,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              borderRadius: BorderRadius.circular(12),
              onPressed: deleteItem,
              icon: Icons.delete,
              backgroundColor: Colors.red,
            )
          ]
        ),
        child: GestureDetector(
          onTap: updateItem,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              ),
            child: Row(
              children: [
                const SizedBox(width: 20,),
          
                // Emoji
                Text(model.emoji,
                  style: 
                  const TextStyle(fontSize: 50)
                ),
          
                const SizedBox(width: 20.0),
          
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.ltr,
                  children: [
                    Text(model.customName, 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),),
          
                    model.daysTillNotification < 1 ? 
                      const Text("Times up! ⏰ Ready to purchase? 🛒")
                      : Text("⏰ ${model.daysTillNotification} days"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}