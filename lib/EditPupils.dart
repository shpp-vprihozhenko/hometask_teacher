import 'package:flutter/material.dart';
import 'AddPupil.dart';
import 'EditPupil.dart';
import 'Pupil.dart';
import 'Services.dart' as MyServices;

class EditPupils extends StatefulWidget {
  final String city, school, teacher, classRoom;
  EditPupils(this.city, this.school, this.teacher, this.classRoom);

  @override
  _EditPupilsState createState() => _EditPupilsState();
}

class _EditPupilsState extends State<EditPupils> {
  List <Pupil> pupilsList = [];

  @override
  void initState() {
    pupilsList.add(Pupil('1', widget.city, widget.school, widget.classRoom, 'Прихоженко Ирина', '123'));
    pupilsList.add(Pupil('2', widget.city, widget.school, widget.classRoom, 'Терентьев Миша', '234'));
    pupilsList.add(Pupil('3', widget.city, widget.school, widget.classRoom, 'Альтаир', '345'));
    pupilsList.add(Pupil('4', widget.city, widget.school, widget.classRoom, 'Настя', '456'));

    MyServices.getPupilsList(pupilsList, widget.city, widget.school, widget.classRoom)
    .then((res){
      pupilsList.sort((el1, el2)=>el1.fio.compareTo(el2.fio));
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classRoom+' класс, школа №'+widget.school+' г.'+widget.city),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Мои ученики:', textScaleFactor: 1.5,),
            Expanded(
              child: Scrollbar(
                child: ListView.builder(
                 itemCount: pupilsList.length,
                 itemBuilder: (BuildContext context, int index) {
                   return Container(
                     color: index%2==1? null : Colors.grey[200],
                     child: InkWell(
                       onTap: () {
                         _editPupil(index);
                       },
                       child: ListTile(
                         title: Text('${index+1}. '+pupilsList[index].fio),
                         subtitle: Text('Пароль: '+pupilsList[index].password),
                         trailing: IconButton(icon: Icon(Icons.edit), onPressed: (){_editPupil(index);},),
                       ),
                     ),
                   );
                 }
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 70, height: 70,
        child: FittedBox(
          child: FloatingActionButton(
            //backgroundColor: Colors.blu,
            //foregroundColor: Colors.black,
            heroTag: 'btnOk',
            onPressed: _addPupil,
            tooltip: 'Подтвердить',
            child: Icon(Icons.add, size: 35,),//      bottomNavigationBar: Container(
          ),
        ),
      ),
    );
  }

  _addPupil(){
    print('add pupil cmd');
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPupil(widget.city, widget.school, widget.teacher, widget.classRoom)))
    .then((newPupil){
      if (newPupil == null) {
        return;
      }
      pupilsList.add(newPupil);
      setState((){});
    });
  }

  void _editPupil(int index) {
    print('edit pupil data $index');
    Pupil pupilToEdit = pupilsList[index];
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditPupil(pupilToEdit)))
    .then((value){
      setState((){});
    });
  }

}
