import 'package:flutter/material.dart';
import 'Services.dart' as MyServices;
import 'Teacher.dart';

class EditTeacher extends StatefulWidget {
  final Teacher teacher;
  EditTeacher(this.teacher);

  @override
  _EditTeacherState createState() => _EditTeacherState();
}

class _EditTeacherState extends State<EditTeacher> {
  TextEditingController _pwdEditingController=TextEditingController();

  @override
  void initState() {
    super.initState();
    _pwdEditingController.text = widget.teacher.pwd;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Изменяем пароль учителя'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              maxLines: 1,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(labelText: 'Пароль'),
              controller: _pwdEditingController,
              maxLength: 20,
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
    print('save with pwd ${_pwdEditingController.text}');
    String newPwd = _pwdEditingController.text.trim();
    MyServices.updateTeacher(widget.teacher, newPwd, context)
    .then((result){
      print('got $result on edit');
      if (result != null) {
        widget.teacher.pwd = newPwd;
        Navigator.pop(context, widget.teacher);
      }
    });
  }

}
