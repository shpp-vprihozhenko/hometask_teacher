import 'package:flutter/material.dart';
import 'AddTask.dart';
import 'CheckTask.dart';
import 'EditPupils.dart';
import 'EditSettings.dart';
import 'HomeTask.dart';
import 'Services.dart' as MyServices;
import 'EditTask.dart';
import 'ShowArchive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Домашнее задание. Учитель.',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Домашнее задание. Учитель.'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final classRoom = '4Д';
  final school = '7';
  final city = 'Черноморск';
  final teacher = 'Наталья Викторовна';
  final List <String> pupilsList = ['Прихоженко Ирина', 'Терентьев Миша', 'Попик Дима'];
  final List <HomeTask> homeTasks = [];

  @override
  void initState() {
    getHomeTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classRoom+' г.'+city+' школа №'+school),
        leading: IconButton(icon: Icon(Icons.refresh), onPressed: getHomeTasks,),
      ),
      body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Выданные ДЗ', textScaleFactor: 2,),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: homeTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: (){_openTask(index);},
                        child: ListTile(
                          tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                          //leading: Text(homeTasks[index].lesson),
                          title: Text(homeTasks[index].lesson+': '+homeTasks[index].fullDescription),
                          subtitle: Text(homeTasks[index].dtStart.toString().substring(0,10)+' - '+homeTasks[index].dtDeadline.toString().substring(0,10)),
                          trailing: Container(
                            width: 100,
                            height: 30,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  iconSize: 20,
                                  color: Colors.deepPurple[900],
                                  icon: Icon(Icons.edit),
                                  onPressed:(){
                                    _editTask(index);
                                  },
                                ),
                                IconButton(
                                  iconSize: 20,
                                  color: Colors.deepPurple[900],
                                  icon: Icon(Icons.account_balance),
                                  onPressed:(){
                                    _moveToArchive(context, index);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      );
                    },
                  ),
                ),)
            ],
          )
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnAddNewTask',
        onPressed: _addNewTask,
        tooltip: 'Новое задание',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: Container(
        //color: Colors.brown[300],
        height: 60,
        child: ButtonBar(
          alignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          //buttonPadding: EdgeInsets.all(3),
          children: [
            FloatingActionButton(onPressed: _showAbout, tooltip: 'О программе', child: Text('?', textScaleFactor: 2,), heroTag: "btnAbout",),
            FloatingActionButton(onPressed: _editPupils, tooltip: 'Ученики', child: Icon(Icons.account_circle, size: 40,), heroTag: "btnPupils"),
            FloatingActionButton(onPressed: _showArchive, tooltip: 'Архив', child: Icon(Icons.account_balance, size: 33,), heroTag: "btnArcTasks"),
            FloatingActionButton(onPressed: _settingsPage, tooltip: 'Настройки', child: Icon(Icons.settings, size: 40,), heroTag: "btnSettings"),
          ],
        )
      ),
    );
  }

  void _moveToArchive(BuildContext context, int index) {
    MyServices.askYesNo(context, 'Перести в архив?')
    .then((value){
      print('got val on ask $value');
      if (value == null || value == false) return;
      MyServices.archTask(homeTasks[index], true)
          .then((res){
        print('got res on arch $res');
        if (res != 'OK') {
          MyServices.showAlertPage(context, res);
        } else {
          homeTasks.removeWhere((item) => item.id == homeTasks[index].id);
          setState((){});
        }
      });
    });
  }

  _editPupils(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditPupils(city, school, teacher, classRoom)));
  }

  _showArchive(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowArchive(city, school, teacher, classRoom)))
    .then((value){
      getHomeTasks();
    });
  }

  _showAbout(){
    MyServices.showAlertPage(context, 'разработчик: \nПрихоженко Владимир, \nvprihogenko@gmail.com');
  }

  _addNewTask(){
    print('add task');
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask(classRoom, city, school, teacher)))
    .then((result){
      print('got add result $result');
      if (result != null) {
        setState(() {
          homeTasks.add(result);
        });
      }
    });
  }

  void getHomeTasks() {
    MyServices.getHomeTasks(homeTasks, city, school, teacher, classRoom, false)
    .then((value) {
      setState((){});
    });
    print('update homeTasks list ${homeTasks.length}');
  }

  _openTask(int index) {
    print('here I\'ll open task $index to check by teacherrt');
    HomeTask task = homeTasks[index];
    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckTask(task, classRoom, city, school, teacher)));
  }

  _editTask(index) {
    HomeTask taskToEdit = homeTasks[index];
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditTask(taskToEdit, classRoom, city, school, teacher)))
        .then((result){
      print('got edit result $result');
      if (result != null) {
        setState(() {});
      }
    });
  }

  _settingsPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditSettings(city, school, teacher, classRoom)));
  }
}
