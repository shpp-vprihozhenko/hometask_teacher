import 'SchoolsTab.dart';
import 'Services.dart' as MyServices;
import 'package:flutter/material.dart';
import 'CitiesTab.dart';
import 'LessonsTab.dart';
import 'TeachersTab.dart';
import 'globals.dart' as globals;

class EditSettings extends StatefulWidget {
  final String city, school, teacher, classRoom, teacherId;
  final int lang;
  EditSettings(this.city, this.school, this.teacher, this.classRoom, this.teacherId, this.lang);

  @override
  _EditSettingsState createState() => _EditSettingsState();
}

class _EditSettingsState extends State<EditSettings> {
  int lang;

  @override
  void initState() {
    lang = widget.lang;
    super.initState();
    _getGlobalsData();
  }

  _getGlobalsData(){
    MyServices.getTeachers(globals.teachers, widget.city, widget.school, widget.teacherId)
    .then((value){
      print('got teachers from EditSettings');
    });
    MyServices.getLessons().then((value) {
      if (value != null && value.length > 0) {
        globals.lessons.clear();
        value.forEach((el){
          globals.lessons.add(el);
        });
      }
      globals.lessons.sort((el1, el2) => el1.compareTo(el2));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.apartment, size: 35,)),
                Tab(icon: Icon(Icons.people, size: 35)),
                Tab(icon: Icon(Icons.calculate, size: 35)),
                Tab(icon: Icon(Icons.school, size: 35)),
              ],
            ),
            title: Row(
              children: [
                Expanded(child: Text(MyServices.msgs['Настройки'][lang])),
                IconButton(icon: Icon(Icons.language), onPressed: _changeLang,)
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.keyboard_backspace),
              onPressed: (){
                Navigator.pop(context, lang);
              },
            ),
          ),
          body: TabBarView(
            children: [
              CitiesTab(lang),
              TeachersTab(widget.city, widget.school, widget.teacherId, lang),
              LessonsTab(lang),
              SchoolsTab(),
            ],
          ),
        )
      )
    );
  }

  _changeLang(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang == 0? 'Язык программы: Русский':'Мова програми: Українська', textAlign: TextAlign.center,),
                SizedBox(height: 10),
                FlatButton(
                  color: lang == 0? Colors.yellow : Colors.lightBlueAccent,
                  child: lang == 0? Text('Змінити на Українську'):Text('Поменять на Русский'),
                  onPressed: (){
                    Navigator.pop(context, lang == 0? 1:0);
                  },
                ),
              ],
            ),
          );
        }
    ).then((value){
      if (value == null) return;
      print('new lang value $value');
      lang = value;
      globals.lang = lang;
      setState(() {});
    });

  }
}
