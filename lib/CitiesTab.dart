import 'package:flutter/material.dart';
import 'Services.dart' as MyServices;
import 'AddCity.dart';
import 'City.dart';
import 'globals.dart' as globals;

class CitiesTab extends StatefulWidget {
  final int lang;
  CitiesTab(this.lang);

  @override
  _CitiesTabState createState() => _CitiesTabState();
}

class _CitiesTabState extends State<CitiesTab> {
  List<City> cities = [];

  @override
  void initState() {
    if (globals.cities.length == 0) {
      MyServices.getCitiesList(cities).then((value) {
        cities.sort((el1, el2)=>el1.name.compareTo(el2.name));
        globals.cities.clear(); cities.forEach((element){globals.cities.add(element);});
        setState(() {});
      });
    } else {
      cities.clear();
      globals.cities.forEach((element) {cities.add(element);});
      print('got cities from globals');
    }
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
            child: Text(MyServices.msgs['Наши города'][widget.lang], textScaleFactor: 1.5,),
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddCity(widget.lang)))
        .then((value){
      if (value != null) {
        cities.add(value);
        globals.cities.clear(); cities.forEach((element){globals.cities.add(element);});
        setState((){});
      }
    });
  }

}
