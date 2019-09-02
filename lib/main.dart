import 'dart:convert';
import 'package:flutter/material.dart';
import 'models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Primeiro APP',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {

  var items = new List<Item>();

//  HomePage(){
//    items = [];
////    items.add(Item(title: "teste1", done: true));
////    items.add(Item(title: "teste2", done: true));
////    items.add(Item(title: "teste3", done: false));
////    items.add(Item(title: "teste4", done: false));
//  }


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTxtCtrl = TextEditingController();

  void add(){

    if(newTxtCtrl.text.isEmpty)
      return;

    setState(() {
      widget.items.add(Item(
        title: newTxtCtrl.text,
        done: false
      ));

      newTxtCtrl.clear();
    });

    save();
  }

  void remove(int index){
    widget.items.removeAt(index);
    save();
  }

  Future load() async {
    var pref = await SharedPreferences.getInstance();

    var data = pref.getString('data');

    if(data != null){
      Iterable decoded  = jsonDecode(data);

      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var pref = await SharedPreferences.getInstance();
    
    await pref.setString('data', jsonEncode(widget.items));
  }

  _HomePageState(){
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTxtCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),

          decoration: InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        )
      ),

      body: ListView.builder(
        itemCount: widget.items.length,

        itemBuilder: (BuildContext context, int index){
          final item = widget.items[index];

          return Dismissible(
            child: CheckboxListTile(
              title: Text(widget.items[index].title),

              value: item.done,

              onChanged: (value){
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),

            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),

            onDismissed: (direction){
              remove(index);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: add,

        child: Icon(Icons.add),

        backgroundColor: Colors.green,
      ),
    );
  }
}
