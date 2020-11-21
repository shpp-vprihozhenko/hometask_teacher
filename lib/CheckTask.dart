import 'package:flutter/material.dart';
import 'CheckPupilSolution.dart';
import 'PhotoView.dart';
import 'Pupil.dart';
import 'PupilSolution.dart';
import 'PupilTaskState.dart';
import 'Services.dart' as MyServices;

class CheckTask extends StatefulWidget {
  final task, classRoom, city, school, teacher;

  CheckTask(this.task, this.classRoom, this.city, this.school, this.teacher);

  @override
  _CheckTaskState createState() => _CheckTaskState();
}

class _CheckTaskState extends State<CheckTask> {
  List <Widget> filesList = [];
  ScrollController _sc = ScrollController();
  List <Pupil> pupilsList = [];
  List <PupilTaskState> pupilTaskStateList = [];

  @override
  void initState() {
    _loadTaskImages();
    _loadPupilsAndStates();
    super.initState();
  }

  _loadPupilsAndStates() async {
    print('load pupils');
    await MyServices.getPupilsList(pupilsList, widget.city, widget.school, widget.classRoom);
    pupilsList.sort((el1, el2)=>el1.fio.compareTo(el2.fio));
    setState((){});
    await MyServices.fillPupilsTaskStateList(pupilsList, widget.task, pupilTaskStateList);
    print('got pupilTaskStateList into checkTask $pupilTaskStateList');
    pupilsList.forEach((pupil) {
      String state = '';
      pupilTaskStateList.forEach((element) {
        if (element.pupilId == pupil.id) {
          state = element.state;
        }
      });
      pupil.curTaskState = state;
    });
    setState((){});
  }

  _loadTaskImages() {
    MyServices.getTaskImagesList(widget.task.id)
    .then((imgList){
      if (imgList.length > 0){
        imgList.forEach((fileName){
          print(fileName);
          _loadTaskImageFromServer(fileName);
        });
      }
    });
  }

  _loadTaskImageFromServer(fileName) {
    widget.task.linksToPhotos.clear();
    MyServices.loadImageFromServer(fileName)
        .then((imageWidget){
      print('_loadImageFromServer with $imageWidget');
      if (imageWidget != null) {
        print('add to fileList');
        widget.task.linksToPhotos.add(fileName);
        filesList.add(imageWidget);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Проверка задания '+widget.classRoom+' класса'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Урок: ', textScaleFactor: 1.1,),
                Text(widget.task.lesson, textScaleFactor: 1.2, style: TextStyle(color: Colors.blueAccent),),
              ],
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                Text('Текст ДЗ: ', textScaleFactor: 1.1,),
                Text(widget.task.fullDescription, textScaleFactor: 1.3, style: TextStyle(color: Colors.blueAccent),),
              ],
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                Text('Сроки: ', textScaleFactor: 1.1,),
                Text(MyServices.dateRus(widget.task.dtStart)+' - '+MyServices.dateRus(widget.task.dtDeadline), textScaleFactor: 1.1, style: TextStyle(color: Colors.blue),),
              ],),
            SizedBox(height: 8,),
            filesList.length == 0? SizedBox()
                : Container(
              height: 60, width: double.infinity,
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _sc,
                child: ListView.builder(
                    controller: _sc,
                    scrollDirection: Axis.horizontal,
                    itemCount: filesList.length,
                    itemBuilder:  (BuildContext context, int index) {
                      int backIdx =  filesList.length - index - 1;
                      return GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: filesList[backIdx],
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoView(filesList[backIdx])));
                        },
                      );
                    }
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Статус выполнения учениками:', textScaleFactor: 1.2, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                )
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: pupilsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: index%2==0? null : Colors.grey[200],
                      child: ListTile(
                        onTap: (){ _checkPupilTask(pupilsList[index]); },
                        title: Text('${index+1}. '+pupilsList[index].fio),
                        trailing: pupilsList[index].curTaskState=='-'? Icon(Icons.done, color: Colors.green[900], size: 28,)
                          : Text(pupilsList[index].curTaskState, textScaleFactor: 1.3, style: TextStyle(color: Colors.green[900])),
                      ),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  _checkPupilTask(pupil) {
    print('check solution of $pupil');
    if (pupil.curTaskState == '') {
      MyServices.showAlertPage(context, 'Задача ещё не решена учеником.');
      return;
    }
    PupilSolution pupilSolution = PupilSolution('', widget.task.id, pupil.id, [], '', '');
    Navigator.push(context, MaterialPageRoute(builder: (context) => CheckPupilSolution(pupilSolution)))
    .then((value){
      if (value == null) return;
      if (pupilSolution.mark != ''){
        pupil.curTaskState = pupilSolution.mark;
        setState(() {});
      }
    });
  }
}
