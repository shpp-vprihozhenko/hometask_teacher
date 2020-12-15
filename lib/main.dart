import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddTask.dart';
import 'CheckTask.dart';
import 'ChooseClassRoomWidget.dart';
import 'EditPupils.dart';
import 'EditSettings.dart';
import 'HomeTask.dart';
import 'IdentifyTeacher.dart';
import 'Services.dart' as MyServices;
import 'EditTask.dart';
import 'ShowArchive.dart';
import 'Teacher.dart';
import 'package:devicelocale/devicelocale.dart';
import 'globals.dart' as globals;

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
  int lang = 0;
  String classRoom = '4Д';
  String school = '7';
  String city = 'Черноморск';
  String fio = 'Наталья Викторовна';
  String teacherId = '';
  Teacher teacher = Teacher('','','','');

  final List <String> pupilsList = ['Прихоженко Ирина', 'Терентьев Миша', 'Попик Дима'];
  final List <HomeTask> homeTasks = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkIdentification(context));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    List languages;
    String currentLocale;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      languages = await Devicelocale.preferredLanguages;
      print(languages);
    } on PlatformException {
      print("Error obtaining preferred languages");
    }
    try {
      currentLocale = await Devicelocale.currentLocale;
      print(currentLocale);
    } on PlatformException {
      print("Error obtaining current locale");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    print('got phone languages $languages');
    print('got currentLocale $currentLocale');
    if (currentLocale == 'uk_UA') {
      print('change program language to UA');
      lang = 1;
      setState(() {});
    }
  }

  checkIdentification(ctx) async {
    print('check id');
    await initPlatformState();
    SharedPreferences prefs = await _prefs;

    int _lang = prefs.getInt('lang');
    print('got lang from prefs $_lang');
    if (_lang != null) {
      lang = _lang;
    }
    globals.lang = lang;

    String _id = prefs.getString('id') ?? '';
    if (_id == null || _id == '') {
      print('no id - identify pupil');
      while (teacher.id == null || teacher.id == '') {
        var res = await Navigator.push(ctx, MaterialPageRoute(builder: (context) => IdentifyTeacher(lang)));
        if (res != null) {
          teacher = res;
        }
      }
      print('got teacher $teacher');
      saveTeacherData(prefs);
    } else {
      getTeacherData(prefs);
    }
    print('got id ${teacher.id}');
    fio = teacher.fio; city = teacher.city; school = teacher.school; classRoom = teacher.classRoom; teacherId = teacher.id;

    if (classRoom=='') {
      classRoom = '4Д';
    }

    setState((){});
    getHomeTasks();
  }

  getTeacherData(prefs){
    teacher.id = prefs.getString('id');
    teacher.city = prefs.getString('city');
    teacher.school = prefs.getString('school');
    teacher.classRoom = prefs.getString('classRoom');
    teacher.fio = prefs.getString('fio');
    print('teacher data restored from SharedPreferences $teacher');
  }

  saveTeacherData(prefs){
    prefs.setString("id", teacher.id);
    prefs.setString("city", teacher.city);
    prefs.setString("school", teacher.school);
    prefs.setString("classRoom", teacher.classRoom);
    prefs.setString("fio", teacher.fio);
    print('pupil data saved into SharedPreferences $teacher');
  }

  _choosePreferredClassRoom(){
    print('_choosePreferredClassRoom $classRoom');
    int classLevel = int.parse(classRoom.substring(0,1));
    print('cur class $classLevel ${classRoom.substring(1,2)}');
    List<String> classLetters = ['А','Б','В','Г','Д','Е','Ж','З','И','К'];
    int classLetterNumber = classLetters.indexOf(classRoom.substring(1,2));
    if (classLetterNumber==-1) classLetterNumber = 0;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: ChooseClassRoomWidget(classRoom, lang),
          );
        }
    ).then((value){
      if (value == null) return;
      if (classRoom != value) {
        setState(() {
          classRoom = value;
        });
        getHomeTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FlatButton(child: Text(classRoom+' класс', textScaleFactor: 1.6, style: TextStyle(color: Colors.white),), onPressed: _choosePreferredClassRoom,),
        leading: IconButton(icon: Icon(Icons.refresh), onPressed: getHomeTasks,),
      ),
      body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(MyServices.msgs['Выданные ДЗ'][lang], textScaleFactor: 2,),
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
    MyServices.askYesNo(context, MyServices.msgs['Перенести в архив?'][lang], lang)
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditPupils(city, school, fio, classRoom, lang)));
  }

  _showArchive(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => ShowArchive(city, school, fio, classRoom, lang)))
    .then((value){
      getHomeTasks();
    });
  }

  _showAbout(){
    MyServices.showAlertPage(context, MyServices.msgs['Разработчик: \nПрихоженко Владимир, \nvprihogenko@gmail.com'][lang]);
  }

  _addNewTask(){
    print('add task');
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddTask(classRoom, city, school, fio, lang)))
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
    MyServices.getHomeTasks(homeTasks, city, school, fio, classRoom, false)
    .then((value) {
      setState((){});
    });
    print('update homeTasks list ${homeTasks.length}');
  }

  _openTask(int index) {
    print('here I\'ll open task $index to check by teacherrt');
    HomeTask task = homeTasks[index];
    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckTask(task, classRoom, city, school, fio, lang)));
  }

  _editTask(index) {
    HomeTask taskToEdit = homeTasks[index];
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditTask(taskToEdit, classRoom, city, school, fio, lang)))
        .then((result){
      print('got edit result $result');
      if (result != null) {
        setState(() {});
      }
    });
  }

  _settingsPage(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditSettings(city, school, fio, classRoom, teacherId, lang)))
    .then((value){
      print('got lang value in main $value');
      if (value == null) return;
      if (value == lang) return;
      lang = value;
      print('update lang to $lang');
      globals.lang = lang;
      setState(() {});
      _saveLangPrefs();
    });
  }

  _saveLangPrefs() async {
    SharedPreferences prefs = await _prefs;
    prefs.setInt("lang", lang);
  }

}
