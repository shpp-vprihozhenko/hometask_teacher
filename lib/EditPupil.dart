import 'package:flutter/material.dart';
import 'Pupil.dart';
import 'Services.dart' as MyServices;

class EditPupil extends StatefulWidget {
  final Pupil pupil;
  final int lang;
  EditPupil(this.pupil, this.lang);

  @override
  _EditPupilState createState() => _EditPupilState();
}

class _EditPupilState extends State<EditPupil> {
  TextEditingController _fioEditingController=TextEditingController();
  TextEditingController _pwdEditingController=TextEditingController();

  @override
  void initState() {
    _fioEditingController.text = widget.pupil.fio;
    _pwdEditingController.text = widget.pupil.password;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyServices.msgs['Изменяем данные ученика'][widget.lang]),
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
    String newFio = _fioEditingController.text.trim();
    String newPwd = _pwdEditingController.text.trim();
    if (newFio == '') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите фамилию и имя'][widget.lang]);
      return;
    }
    if (newPwd == '') {
      MyServices.showAlertPage(context, MyServices.msgs['Укажите пароль'][widget.lang]);
      return;
    }
    MyServices.editPupil(widget.pupil.id, newFio, newPwd)
    .then((result){
      print('got $result on edit');
      if (result != null) {
        widget.pupil.fio = newFio;
        widget.pupil.password = newPwd;
        Navigator.pop(context);
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
