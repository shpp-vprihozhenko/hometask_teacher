import 'package:flutter/material.dart';
import 'AddTeacher.dart';
import 'EditTeacher.dart';
import 'Services.dart' as MyServices;
import 'Teacher.dart';
import 'globals.dart' as globals;

class TeachersTab extends StatefulWidget {
  final String city, school, teacherId;
  final int lang;
  TeachersTab(this.city, this.school, this.teacherId, this.lang);

  @override
  _TeachersTabState createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  List <Teacher> teachers = [];
  bool showAll = false;

  @override
  void initState() {
//    teachers.add(Teacher('Шулянська Наталія Вікторівна', "Черноморск", "7", "4Д")); ритто1у
//    teachers.add(Teacher('Сестриватовська Тетяна Миколаївна', "Черноморск", "7", "4В"));
//    teachers.add(Teacher('Мазур Ірина Володимирівна', "Черноморск", "7", "4Е"));
//    teachers.add(Teacher('Ісупова Ельвіра Федорівна', "Черноморск", "7", "4Г"));
//    teachers.add(Teacher('Жирик Любов Сергіївна', "Черноморск", "7", "4Б"));
//    teachers.add(Teacher('Ерментраут Лілія Олександрівна', "Черноморск", "7", "4А"));
    super.initState();
    if (globals.teachers.length == 0) {
      MyServices.getTeachers(teachers, widget.city, widget.school, widget.teacherId)
          .then((value){
        print('got teachers with');
        setState(() {});
      });
    } else {
      globals.teachers.forEach((element) {teachers.add(element);});
      print('fill teachers from globals ${teachers.length}');
    }
  }

  _loadAllTeachers(){
    showAll = true;
    MyServices.getTeachers(teachers, '', '', widget.teacherId)
    .then((value){
      print('got teachers with');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(MyServices.msgs['Наши учителя'][widget.lang], textScaleFactor: 1.5,),
          ),
          showAll?
          SizedBox()
          :
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('школа № ${widget.school} г. ${widget.city}', textScaleFactor: 1.3,),
              IconButton(icon: Icon(Icons.clear), onPressed: _loadAllTeachers)
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                    title: Text(teachers[index].fio, textAlign: TextAlign.center,),
                    subtitle: showAll?
                      Column(children: [
                        Text("шк. №"+teachers[index].school+" г. "+teachers[index].city),
                        teachers[index].pwd==null? SizedBox() : Text(teachers[index].pwd),
                      ],)
                      :teachers[index].pwd==null? SizedBox() : Text(teachers[index].pwd),
                    trailing: teachers[index].pwd==null? SizedBox() : IconButton(icon: Icon(Icons.edit), onPressed: (){_editTeacher(index);}),
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnAddNewTeacher',
        onPressed: _addNewTeacher,
        tooltip: 'Добавить учителя',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _editTeacher(index){
    Teacher teacher = teachers[index];
    print('req to edit teacher $index');
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditTeacher(teacher)))
    .then((value){
      if (value != null) {
        teachers[index] = value;
        setState((){});
      }
    });
  }

  _addNewTeacher(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddTeacher(widget.city, widget.school, widget.teacherId, widget.lang)))
        .then((value){
      if (value != null) {
        teachers.add(value);
        globals.teachers.clear(); globals.teachers.forEach((element) {teachers.add(element);});
        setState((){});
      }
    });
  }

}
