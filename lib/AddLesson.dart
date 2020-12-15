import 'package:flutter/material.dart';
import 'Services.dart' as MyServices;

class AddLesson extends StatefulWidget {
  final int lang;
  AddLesson(this.lang);

  @override
  _AddLessonState createState() => _AddLessonState();
}

class _AddLessonState extends State<AddLesson> {
  TextEditingController _tc=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('+ урок'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: TextField(
            maxLines: 2,
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(labelText: MyServices.msgs['Новый урок'][widget.lang]),
            controller: _tc,
            maxLength: 200,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnDone',
        onPressed: _done,
        tooltip: 'Добавить урок',
        child: Icon(Icons.done),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _done(){
    String newLesson = _tc.text.trim();
    print('got lesson $newLesson');
    if (newLesson == '') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите название урока'][widget.lang]);
      return;
    }
    /*
    RegExp _regExp = RegExp(r'^[a-zA-Z_ .А-Яа-яіІєЄїЇ’їі]*$');
    if (!_regExp.hasMatch(newLesson)){
      MyServices.showAlertPage(context, 'Укажите корректное название урока.');
      return;
    }
     */
    MyServices.addLesson(newLesson, context)
    .then((newLesson){
      if (newLesson == null) {
        return;
      }
      Navigator.pop(context, newLesson);
    });
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

}
