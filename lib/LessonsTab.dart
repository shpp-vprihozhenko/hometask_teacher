import 'package:flutter/material.dart';
import 'AddLesson.dart';
import 'Services.dart' as MyServices;
import 'globals.dart' as globals;

class LessonsTab extends StatefulWidget {
  final int lang;
  LessonsTab(this.lang);

  @override
  _LessonsTabState createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab> {
  List<String> lessons = [];

  @override
  void initState() {
    super.initState();
    if (globals.lessons.length == 0) {
      MyServices.getLessons().then((value) {
        if (value != null && value.length > 0) {
          lessons.clear();
          value.forEach((el){
            lessons.add(el);
          });
        }
        lessons.sort((el1, el2) => el1.compareTo(el2));
        setState(() {});
      });
    } else {
      globals.lessons.forEach((element) {lessons.add(element);});
      print('got lessons from globals');
    }
  }

  @override
  Widget build(BuildContext context) { //Терентьев Миша
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(MyServices.msgs['В программу добавлены уроки:'][widget.lang], textScaleFactor: 1.5,),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: lessons.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                      title: Text(lessons[index], textAlign: TextAlign.center,)
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnAddNewLesson',
        onPressed: _addLesson,
        tooltip: 'Добавить урок',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _addLesson(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddLesson(widget.lang)))
        .then((value){
      if (value != null) {
        lessons.add(value);
        globals.lessons.clear(); globals.lessons.forEach((element) {lessons.add(element);});
        setState((){});
      }
    });
  }

}
