import 'package:flutter/material.dart';
import 'Services.dart' as MyServices;
import 'AddCity.dart';
import 'City.dart';
import 'Teacher.dart';

class EditSettings extends StatefulWidget {
  final String city, school, teacher, classRoom;
  EditSettings(this.city, this.school, this.teacher, this.classRoom);

  @override
  _EditSettingsState createState() => _EditSettingsState();
}

class _EditSettingsState extends State<EditSettings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.apartment, size: 35,)),
                Tab(icon: Icon(Icons.people, size: 35)),
              ],
            ),
            title: Text('Доп. настройки'),
            leading: IconButton(
              icon: Icon(Icons.keyboard_backspace),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),
          body: TabBarView(
            children: [
              CitiesTab(),
              TeachersTab(),
            ],
          ),
        )
      )
    );
  }

}

class CitiesTab extends StatefulWidget {
  @override
  _CitiesTabState createState() => _CitiesTabState();
}

class _CitiesTabState extends State<CitiesTab> {
  List<City> cities = [];

  @override
  void initState() {
    MyServices.getCitiesList(cities).then((value) {
      cities.sort((el1, el2)=>el1.name.compareTo(el2.name));
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) { //Терентьев Миша
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Наши города', textScaleFactor: 1.5,),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                    title: Text(cities[index].name, textAlign: TextAlign.center,)
                );
              }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnAddNewCity',
        onPressed: _addNewCity,
        tooltip: 'Добавить город',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _addNewCity(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddCity()))
    .then((value){
      if (value != null) {
        cities.add(value);
        setState((){});
      }
    });
  }

}


class TeachersTab extends StatefulWidget {
  @override
  _TeachersTabState createState() => _TeachersTabState();
}

class _TeachersTabState extends State<TeachersTab> {
  List <Teacher> teachers = [];

  @override
  void initState() {
    teachers.add(Teacher('Шулянська Наталія Вікторівна', "Черноморск", "7", "4Д"));
    teachers.add(Teacher('Сестриватовська Тетяна Миколаївна', "Черноморск", "7", "4В"));
    teachers.add(Teacher('Мазур Ірина Володимирівна', "Черноморск", "7", "4Е"));
    teachers.add(Teacher('Ісупова Ельвіра Федорівна', "Черноморск", "7", "4Г"));
    teachers.add(Teacher('Жирик Любов Сергіївна', "Черноморск", "7", "4Б"));
    teachers.add(Teacher('Ерментраут Лілія Олександрівна', "Черноморск", "7", "4А"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Наши учителя', textScaleFactor: 1.5,),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                      tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(teachers[index].city),
                          Text('Школа № '+teachers[index].school),
                          Text('Осн. класс '+teachers[index].classRoom),
                          Text(teachers[index].fio),
                        ],
                      )
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

  _addNewTeacher(){

  }

}
