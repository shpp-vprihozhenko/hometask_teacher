import 'dart:math';
import 'package:flutter/material.dart';
import 'Pupil.dart';
import 'Services.dart' as MyServices;

class AddPupil extends StatefulWidget {
  final String city, school, teacher, classRoom;
  final int lang;
  AddPupil(this.city, this.school, this.teacher, this.classRoom, this.lang);

  @override
  _AddPupilState createState() => _AddPupilState();
}

class _AddPupilState extends State<AddPupil> {
  TextEditingController _fioEditingController=TextEditingController();
  TextEditingController _pwdEditingController=TextEditingController();

  @override
  void initState() {
    var r = Random();
    const _chars = 'ЙйЦцУуКкЕеНнГгШШщЩЗзХхЪъФфВвАаПпРрОоЛлДдЖжЭэЯяЧчСсМмИиТтЬьБбЮю';
    _pwdEditingController.text = List.generate(6, (index) => _chars[r.nextInt(_chars.length)]).join();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyServices.msgs['Добавляем нового ученика'][widget.lang]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              maxLines: 2,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(labelText: MyServices.msgs['Фамилия и имя'][widget.lang]),
              controller: _fioEditingController,
              maxLength: 200,
            ),
            SizedBox(height: 20,),
            TextField(
              maxLines: 1,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(labelText: 'Пароль'),
              controller: _pwdEditingController,
              maxLength: 15,
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 80, height: 80,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            heroTag: 'btnOk',
            onPressed: _saveCmd,
            tooltip: 'Подтвердить',
            child: Icon(Icons.done_rounded, size: 40,),//      bottomNavigationBar: Container(
          ),
        ),
      ),
    );
  }

  _saveCmd(){
    print('save with ${_fioEditingController.text} pwd ${_pwdEditingController.text}');
    if (_fioEditingController.text.trim()=='') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите фамилию и имя'][widget.lang]);
      return;
    }
    if (_pwdEditingController.text.trim()=='') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите пароль'][widget.lang]);
      return;
    }
    Pupil newPupil = Pupil('', widget.city, widget.school, widget.classRoom, _fioEditingController.text.trim(), _pwdEditingController.text.trim());
    MyServices.addPupil(newPupil)
    .then((pupil){
      print('got $pupil on add');
      if (pupil != null) {
        Navigator.pop(context, pupil);
      }
    });
  }

  @override
  void dispose() {
    _fioEditingController.dispose();
    _pwdEditingController.dispose();
    super.dispose();
  }

}
