import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Tasks!',
      home: MyList(),
    );
  }
}
/*
class Tasks extends StatelessWidget {
  final List<String> names = <String>[
    'Aby',
    'Aish',
    'Ayan',
    'Ben',
    'Bob',
    'Charlie',
    'Cook',
    'Carline'
  ];
  final List<int> msgCount = <int>[2, 0, 10, 6, 52, 4, 0, 2];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beautiful Tasks!'),
      ),
      body: Center(
        child: MyList(
          names: names,
          msgCount: msgCount,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>{MyList.setState((){names.add('abhishek'), msgCount.add(12)});},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
*/

class MyList extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<MyList> {
  void swap(a, b, temp) {
    temp = a;
    a = b;
    b = a;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _nameList async {
    final path = await _localPath;
    return File('$path/nameList.txt');
  }

  Future<File> get _colorList async {
    final path = await _localPath;
    return File('$path/colorList.txt');
  }

  Future<File> writeCounter(List<List<String>> myList, _localFile) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(myList));
  }

  Future<File> makeFileEmpty(_localFile) async {
    final file = await _localFile;
    return file.writeAsString("");
  }

  Future<String> readCounter(_localFile) async {
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0.
      return "[]";
    }
  }

  Color color = Colors.redAccent;
  List<List<String>> names = [];

  List<Color> listColors = <Color>[Colors.redAccent, Colors.greenAccent];
  List<String> colorsBit = <String>[];
  int start = 1;
  int lastNotDone = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController taskToAdd = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var temp;
    if (start == 1) {
      readCounter(_nameList).then((String nameValue) {
        print(nameValue);
        if (nameValue == "" || nameValue == "[]") {
          temp = [
            <String>["All Done", "1"]
          ];
          writeCounter(temp, _nameList);
          //writeCounter(<String>["1"], _colorList);
        } else {
          temp = jsonDecode(nameValue);
        }
        setState(() {
          for (var i = 0; i < temp.length; i++) {
            names.add(<String>["", ""]);
            names[i][0] = temp[i][0];
            names[i][1] = temp[i][1];
            if (temp[i][1] == "0") {
              lastNotDone += 1;
            }
          }
          /*
          for (var i = 0; i < temp.length; i++) {
            names.add(jsonDecode(temp[i]));
          }
*/
          //print(names);
          //print(names.length);
          start = 0;
        });
      });
      /*
      readCounter(_colorList).then((String colorValue) {
        print(colorValue);
        //colorsBit = json.decode(colorValue).cast<int>();
        print(colorsBit);
      });*/
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Beautiful Tasks!'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: names.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = names[index][0];
                    //print(item);

                    return Dismissible(
                      // Each Dismissible must contain a Key. Keys allow Flutter to
                      // uniquely identify widgets.
                      key: Key(item),
                      // Provide a function that tells the app
                      // what to do after an item has been swiped away.
                      onDismissed: (direction) {
                        // Remove the item from the data source.
                        setState(() {
                          if (names[index][1] == "0") {
                            lastNotDone -= 1;
                          }
                          names.removeAt(index);
                          writeCounter(names, _nameList);
                        });

                        // Then show a snackbar.
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("$item dismissed")));
                      },
                      child: GestureDetector(
                        child: Container(
                          color: listColors[int.parse(names[index][1])],
                          height: 50,
                          margin: EdgeInsets.all(2),
                          child: Center(
                              child: Text(
                            '${item} ',
                            style: TextStyle(fontSize: 18),
                          )),
                        ),
                        onTap: () {
                          setState(() {
                            if (names[index][1] == "0") {
                              List temp;
                              temp = names[lastNotDone - 1];
                              names[lastNotDone - 1] = names[index];
                              names[index] = temp;
                              names[lastNotDone - 1][1] = "1";
                              writeCounter(names, _nameList);
                              if (lastNotDone > 0) {
                                lastNotDone -= 1;
                              }
                            }
                          });
                        },
                      ),
                    );
                  }))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Container(
                    height: 100.0,
                    width: 860.0,
                    color: Colors.white,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        autofocus: true,
                        controller: taskToAdd,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'task empty!';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              names.insert(0, [taskToAdd.text, "0"]);
                              writeCounter(names, _nameList);
                              lastNotDone += 1;
                            });
                            taskToAdd.text = '';
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ),
                );
              })
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
