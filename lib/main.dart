import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Tasks!',
      home: MyList(),
    );
  }
}

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

      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "[]";
    }
  }

  List<List<String>> names = [];

  final scaffoldColor = Colors.purpleAccent;
  List<Color> listColors = <Color>[
    Color.fromRGBO(255, 128, 62, 100),
    Color.fromRGBO(63, 142, 255, 100)
  ];
  List<String> colorsBit = <String>[];
  int start = 1;
  int tasksNotDone = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController taskToAdd = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var temp;
    if (start == 1) {
      readCounter(_nameList).then((String nameValue) {
        if (nameValue == "" || nameValue == "[]") {
          temp = [
            <String>["All Done", "1"]
          ];
          writeCounter(temp, _nameList);
        } else {
          temp = jsonDecode(nameValue);
        }
        setState(() {
          for (var i = 0; i < temp.length; i++) {
            names.add(<String>["", ""]);
            names[i][0] = temp[i][0];
            names[i][1] = temp[i][1];
            if (temp[i][1] == "0") {
              tasksNotDone += 1;
            }
          }
          start = 0;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(138, 255, 127, 100),
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
                    return Dismissible(
                      key: Key(item),
                      onDismissed: (direction) {
                        setState(() {
                          if (names[index][1] == "0") {
                            tasksNotDone -= 1;
                          }
                          names.removeAt(index);
                          writeCounter(names, _nameList);
                        });

                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("$item dismissed")));
                      },
                      child: GestureDetector(
                        child: Container(
                          color: listColors[int.parse(names[index][1])],
                          height: 50,
                          margin: EdgeInsets.all(4),
                          child: Center(
                              child: Text(
                            '${item} ',
                            style: TextStyle(fontSize: 18),
                          )),
                        ),
                        onTap: () {
                          setState(() {
                            var names1 = names;
                            if (names1[index][1] == "0") {
                              List temp;
                              temp = names1[index];
                              temp[1] = "1";
                              names1.removeAt(index);
                              names1.insert(tasksNotDone - 1, temp);
                              writeCounter(names1, _nameList);
                              if (tasksNotDone > 0) {
                                tasksNotDone -= 1;
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
        backgroundColor: Color.fromRGBO(255, 128, 62, 100),
        onPressed: () => {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter some task'),
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
                            tasksNotDone += 1;
                          });
                          taskToAdd.text = '';
                          Navigator.pop(context);
                        }
                      },
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
