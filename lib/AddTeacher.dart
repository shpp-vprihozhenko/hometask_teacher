import 'package:flutter/material.dart';
import 'City.dart';
import 'School.dart';
import 'Services.dart' as MyServices;
import 'Teacher.dart';
import 'globals.dart' as globals;

class AddTeacher extends StatefulWidget {
  final String city, school, teacherId;
  final int lang;
  AddTeacher(this.city, this.school, this.teacherId, this.lang);

  @override
  _AddTeacherState createState() => _AddTeacherState();
}

class _AddTeacherState extends State<AddTeacher> {
  TextEditingController _tec1=TextEditingController();
  TextEditingController _tec2=TextEditingController();
  String newTeacherCity, newTeacherFIO, newTeacherPwd;
  int newTeacherSchool = 0;
  List <DropdownMenuItem<String>> citiesDDI = [];
  String _selectedCity='...', _selectedSchool='...';
  List <DropdownMenuItem<String>> schoolsDDI = [DropdownMenuItem(
    value: '...',
    child: new Text('...', style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
  )];
  bool _showSchoolNumber = true;

  @override
  void initState() {
    super.initState();
    newTeacherSchool = int.parse(widget.school);
    loadCities();
  }

  loadCities(){
    citiesDDI.add(
        DropdownMenuItem(
          value: '...',
          child: new Text('...', style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
        )
    );
    if (globals.cities.length == 0) {
      List <City> _cities = [];
      MyServices.getCitiesList(_cities).then((value) {
        print('got cities $_cities}');
        _cities.sort((el1, el2)=>el1.name.compareTo(el2.name));
        _cities.forEach((city){
          citiesDDI.add(DropdownMenuItem(
            value: city.name,
            child: new Text(city.name, style: TextStyle(color: Colors.blue), textScaleFactor: 1.4,),
          ));
        });
        _selectedCity = widget.city;
        setState(() {});
      });
    } else {
      globals.cities.forEach((city) {
        citiesDDI.add(DropdownMenuItem(
          value: city.name,
          child: new Text(city.name, style: TextStyle(color: Colors.blue), textScaleFactor: 1.4,),
        ));
      });
      print('got cities from globals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyServices.msgs['Добавляем преподавателя'][widget.lang]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            TextField(
              maxLines: 1,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(labelText: MyServices.msgs['ФИО преподавателя'][widget.lang]),
              controller: _tec1,
              maxLength: 100,
            ),
            TextField(
              maxLines: 1,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(labelText: 'Пароль'),
              controller: _tec2,
              maxLength: 30,
            ),
            Row(
              children: [
                Text(MyServices.msgs['Город'][widget.lang]+':  ', textScaleFactor: 1.6,),
                DropdownButton<String>(
                  hint: Text("Город"),
                  value: _selectedCity,
                  items: citiesDDI,
                  onChanged: (String val) {
                    setState(() {
                      _selectedCity = val;
                    });
                    _fillCitySchools();
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
            _showSchoolNumber? _buildSchoolNumberRow() : SizedBox(),
            SizedBox(height: 10,),
            Text(MyServices.msgs['Или выберите школу из списка:'][widget.lang], textScaleFactor: 1.4,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: Text("Школа"),
                  value: _selectedSchool,
                  items: schoolsDDI,
                  onChanged: (String val) {
                    _showSchoolNumber = (val == '...');
                    setState(() {
                      _selectedSchool = val;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: 'btnDone',
        onPressed: _done,
        tooltip: 'Добавить учителя',
        child: Icon(Icons.done, size: 36,),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Row _buildSchoolNumberRow() {
    return Row(
            children: [
              Text('Школа № ', textScaleFactor: 1.6,),
              Text(''+newTeacherSchool.toString()+'  ', textScaleFactor: 2.4, style: TextStyle(color: Colors.blue),),
              FloatingActionButton(heroTag: 'flMinusBtn',
                child: Icon(Icons.remove),
                onPressed: (){ if (newTeacherSchool>1) newTeacherSchool--; setState(() {});}
              ),
              SizedBox(width: 24,),
              FloatingActionButton( heroTag: 'flAddBtn',
                child: Icon(Icons.add),
                onPressed: (){ newTeacherSchool++; setState(() {});}
              ),
            ],
          );
  }

  _fillCitySchools() async {
    print('_fillCitySchools with $_selectedCity');
    if (_selectedCity == '') return;
    List <School> _schools = await MyServices.getSchools(_selectedCity);
    schoolsDDI.clear();
    schoolsDDI.add(
        DropdownMenuItem(
          value: '...',
          child: new Text('...', style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
        )
    );
    _schools.forEach((element) {
      schoolsDDI.add(
          DropdownMenuItem(
            value: element.name,
            child: new Text(element.name, style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
          )
      );
    });
    setState(() {});
  }

  _done(){
    newTeacherFIO = _tec1.text.trim();
    print('got city $newTeacherFIO');
    if (newTeacherFIO == '') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите фамилию и имя'][widget.lang]);
      return;
    }
    /*
    RegExp _regExp = RegExp(r'^[a-zA-Z_ .А-Яа-яіІєЄїЇ’]*$');
    if (!_regExp.hasMatch(newTeacherFIO)){
      MyServices.showAlertPage(context, 'Укажите корректные данные преподавателя.');
      return;
    }
     */
    newTeacherPwd = _tec2.text.trim();
    if (newTeacherPwd == '') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите пароль'][widget.lang]);
      return;
    }
    /*
    if (newTeacherPwd.length < 5) {
      MyServices.showAlertPage(context, 'Укажите пароль с длиной более 4х символов.');
      return;
    }
     */
    if (_selectedCity == '...') {
      MyServices.showAlertPage(context, MyServices.msgs['Выберите город'][widget.lang]);
      return;
    }
    if (newTeacherSchool == 0 && _selectedSchool == '...') {
      MyServices.showAlertPage(context, MyServices.msgs['Выберите школу'][widget.lang]);
      return;
    }

    String _teacherSchool = _selectedSchool == '...'? newTeacherSchool.toString() : _selectedSchool;
    print('got _teacherSchool $_teacherSchool');

    Teacher newTeacher = Teacher(newTeacherFIO, _selectedCity, _teacherSchool, '', ownerId: widget.teacherId, pwd: newTeacherPwd);

    MyServices.addTeacher(newTeacher, context)
    .then((newId){
      if (newId == null) {
        return;
      }
      Navigator.pop(context, newTeacher);
    });
  }

  @override
  void dispose() {
    _tec1.dispose();
    _tec2.dispose();
    super.dispose();
  }
}
