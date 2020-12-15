import 'package:flutter/material.dart';
import 'City.dart';
import 'School.dart';
import 'globals.dart' as globals;
import 'Services.dart' as MyServices;

class SchoolsTab extends StatefulWidget {
  @override
  _SchoolsTabState createState() => _SchoolsTabState();
}

class _SchoolsTabState extends State<SchoolsTab> {
  List <City> cities = [];
  List <School> schools = [];
  String _selectedCity = '';

  @override
  void initState() {
    cities.add(City('','...'));
    globals.cities.forEach((element) {cities.add(element);});
    _selectedCity = cities[0].name;
    print('got cities from globals $cities');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(MyServices.msgs['Город'][globals.lang]+': '),
              DropdownButton<String>(
                hint: Text(MyServices.msgs['Город'][globals.lang]),
                value: _selectedCity,
                items: _citiesDDI(),
                onChanged: (String val) {
                  setState(() {
                    _selectedCity = val;
                    print('sel city $_selectedCity');
                    _refreshSchools();
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: IconButton(icon: Icon(Icons.refresh), onPressed: _refreshSchools,),
              title: Text(MyServices.msgs['Наши школы'][globals.lang], textScaleFactor: 1.5,)
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: schools.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                    title: Text(schools[index].name, textAlign: TextAlign.center,),
                    subtitle: Text(schools[index].city, textAlign: TextAlign.center,),
                    trailing: IconButton(icon: Icon(Icons.edit), onPressed: (){_editSchool(index);}),
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnAddNew',
        onPressed: _addSchool,
        tooltip: 'Добавить школу',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _refreshSchools() async {
    List <School> sch = await MyServices.getSchools(_selectedCity);
    print('got sch $sch');
    schools.clear(); sch.forEach((element) {schools.add(element);});
    setState(() {});
  }

  _citiesDDI() {
    List <DropdownMenuItem<String>> res = [];
    cities.forEach((el) {
      res.add(DropdownMenuItem(
        value: el.name,
        child: Text(el.name, style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
      ));
    });
    return res;
  }

  _editSchool(index){
    print('edit ${schools[index]}');
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: EditSchool(schools[index].name),
          );
        }
    ).then((value){
      if (value == null) return;
      print('got new school $value');
      MyServices.updateSchool(schools[index].id, value)
      .then((value2){
        if (value2 == 'OK') {
          schools[index].name = value;
          setState(() {});
        } else {
          MyServices.showAlertPage(context, 'Ошибка. '+value2);
        }
      });
    });
  }

  _addSchool() {
    print('add new school');
    if (_selectedCity == '...') {
      MyServices.showAlertPage(context, MyServices.msgs['Перед добавлением школы выберите город'][globals.lang]);
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: EditSchool(''),
          );
        }
    ).then((value){
      if (value == null) return;
      print('got new school $value');
      MyServices.addSchool(value, _selectedCity)
      .then((value2){
        if (value2.substring(0, 3)=='err') {
          MyServices.showAlertPage(context, 'Ошибка. '+value2);
        } else {
          schools.add(School(value2, value, _selectedCity));
          setState(() {});
        }
      });
    });
  }
}

class EditSchool extends StatefulWidget {
  final String startName;
  EditSchool(this.startName);

  @override
  _EditSchoolState createState() => _EditSchoolState();
}

class _EditSchoolState extends State<EditSchool> {
  TextEditingController _schoolController = TextEditingController();

  @override
  void initState() {
    _schoolController.text = widget.startName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          maxLines: 2,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(labelText: MyServices.msgs['Название школы'][globals.lang]),
          controller: _schoolController,
          maxLength: 200,
        ),
        FlatButton(
          color: Colors.greenAccent,
          onPressed: (){
            Navigator.pop(context, _schoolController.text);
          },
          child: Text('OK'))
      ],
    );
  }
}
