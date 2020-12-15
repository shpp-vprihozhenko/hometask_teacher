import 'package:flutter/material.dart';
import 'City.dart';
import 'School.dart';
import 'Teacher.dart';
import 'Services.dart' as Service;

class IdentifyTeacher extends StatefulWidget {
  final int lang;
  IdentifyTeacher(this.lang);

  @override
  _IdentifyTeacherState createState() => _IdentifyTeacherState();
}

class _IdentifyTeacherState extends State<IdentifyTeacher> {
  List <String> cities = [];
  String _selectedCity, _selectedSchool = '...';
  TextEditingController _pwdController = TextEditingController();
  TextEditingController _fioController = TextEditingController();
  int schoolNumber = 1;
  List <DropdownMenuItem<String>> schoolsDDI = [DropdownMenuItem(
    value: '...',
    child: new Text('...', style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
  )];
  bool _showSchoolNumber = true;

  @override
  void initState() {
    cities.add('Черноморск');
    cities.add('Харьков');
    cities.add('Донецк');
    _selectedCity = cities[0];
    List <City> _listCities = [];
    Service.getCitiesList(_listCities)
    .then((val){
      if (val == null) return;
      cities.clear();
      _listCities.forEach((element) { cities.add(element.name); });
      _selectedCity = cities[0];
      setState((){});
      _fillCitySchools();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Service.msgs['Идентифицикация'][widget.lang]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Service.msgs['Твой город: '][widget.lang], textScaleFactor: 1.2,),
                  DropdownButton<String>(
                    hint: Text(Service.msgs['Город'][widget.lang]),
                    value: _selectedCity,
                    items: _citiesDDI(),
                    onChanged: (String val) {
                      setState(() {
                        _selectedCity = val;
                      });
                      _fillCitySchools();
                    },
                  ),
                ],
              ),
              Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    _showSchoolNumber? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Твоя школа № ',textScaleFactor: 1.3,),
                        Column(children: [
                          IconButton(icon: Icon(Icons.keyboard_arrow_up), onPressed: (){
                            if (schoolNumber<100)
                              schoolNumber++;
                            setState(() {});
                          }),
                          Text(schoolNumber.toString(), textScaleFactor: 2, style: TextStyle(color: Colors.blue),),
                          IconButton(icon: Icon(Icons.keyboard_arrow_down), onPressed: (){
                            if (schoolNumber>1)
                              schoolNumber--;
                            setState(() {});
                          }),
                        ],),
                      ],
                    ) : SizedBox(),
                    Text(Service.msgs['Или выберите школу из списка:'][widget.lang], textScaleFactor: 1.4,),
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
                  ],
                ),
              ),
              Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    TextField(
                      maxLines: 2,
                      //style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(labelText: Service.msgs['Фамилия и имя'][widget.lang]),
                      controller: _fioController,
                      maxLength: 100,
                    ),
                    TextField(
                      //style: TextStyle(fontSize: 15),
                      decoration: InputDecoration(labelText: Service.msgs['Твой пароль'][widget.lang]),
                      controller: _pwdController,
                      maxLength: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: 'btnDone',
        onPressed: _done,
        tooltip: 'Ок',
        child: Icon(Icons.done),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _fillCitySchools() async {
    print('_fillCitySchools with $_selectedCity');
    if (_selectedCity == '') return;
    List <School> _schools = await Service.getSchools(_selectedCity);
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

  _citiesDDI() {
    List <DropdownMenuItem<String>> res = [];
    cities.forEach((el) {
      res.add(DropdownMenuItem(
        value: el,
        child: Text(el, style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
      ));
    });
    return res;
  }

  _done() async {
    String fio = _fioController.text.trim();
    String pwd = _pwdController.text.trim();
    if (fio == '') {
      Service.showAlertPage(context, Service.msgs['Укажите фамилию и имя'][widget.lang]);
      return;
    }
    if (pwd == '') {
      Service.showAlertPage(context, Service.msgs['Укажите пароль'][widget.lang]);
      return;
    }
    String _teacherSchool = (_selectedSchool == null || _selectedSchool == '...') ? schoolNumber.toString() : _selectedSchool;
    print('identify with г. $_selectedCity школа № $_teacherSchool фио $fio пароль $pwd');
    Teacher teacher = Teacher(fio, _selectedCity, _teacherSchool, '');
    String _id = await Service.identifyTeacher(teacher, pwd, context);
    if (_id != '') {
      teacher.id = _id;
      print ('ok teacher with $teacher');
      Navigator.pop(context, teacher);
    }
  }

}
