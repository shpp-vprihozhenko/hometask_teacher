import 'package:flutter/material.dart';
import 'City.dart';
import 'Services.dart' as MyServices;

class AddCity extends StatefulWidget {
  @override
  _AddCityState createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  TextEditingController _cityController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавляем новый город'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: TextField(
              maxLines: 2,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(labelText: 'Введите название нового города'),
              controller: _cityController,
              maxLength: 200,
            ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btnDone',
        onPressed: _done,
        tooltip: 'Добавить город',
        child: Icon(Icons.done),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _done(){
    String newCity = _cityController.text.trim();
    print('got city $newCity');
    if (newCity == '') {
      MyServices.showAlertPage(context, 'Укажите название города.');
      return;
    }
    RegExp _regExp = RegExp(r'^[a-zA-Z_ .А-Яа-я]*$');
    if (!_regExp.hasMatch(newCity)){
      MyServices.showAlertPage(context, 'Укажите корректное название населённого пункта.');
      return;
    }
    MyServices.addCity(newCity)
    .then((newId){
      if (newId == null) {
        return;
      }
      Navigator.pop(context, City(newId, newCity));
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

}