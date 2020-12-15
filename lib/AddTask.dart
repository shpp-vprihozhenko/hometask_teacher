import 'package:flutter/material.dart';
import 'HomeTask.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'PhotoView.dart';
import 'Services.dart' as MyServices;

class AddTask extends StatefulWidget {
  final classRoom, city, school, teacher;
  final int lang;
  AddTask(this.classRoom, this.city, this.school, this.teacher, this.lang);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {

  File file;
  List <File> filesList = [];
  TextEditingController _textEditingController = TextEditingController();
  DateTime dtDeadline = DateTime.now().add(const Duration(days: 5));
  ScrollController _sc = ScrollController();
  String _selectedLesson = '...';
  bool showProgressWhileSave = false;
  List <DropdownMenuItem<String>> lessonsDDI = [];


  @override
  void initState() {
    loadLessonsDDI();
    super.initState();
  }

  loadLessonsDDI() {
    lessonsDDI.add(
      DropdownMenuItem(
        value: '...',
        child: new Text('...', style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
      )
    );
    MyServices.getLessons()
        .then((value){
      if (value == null) return;
      value.forEach((el){
        print('add to ddm $el');
        lessonsDDI.add(DropdownMenuItem(
          value: el,
          child: new Text(el, style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
        ));
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('+ ДЗ для '+widget.classRoom),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                children: [
                  Text('Урок: ', textScaleFactor: 1.2,),
                  DropdownButton<String>(
                    hint: Text("Урок"),
                    value: _selectedLesson,
                    items: lessonsDDI,
                    onChanged: (String val) {
                      setState(() {
                        _selectedLesson = val;
                      });
                    },
                  ),
                ],
              ),
              TextField(
                maxLines: 2,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(labelText: 'Текст ДЗ'),
                controller: _textEditingController,
                maxLength: 200,
              ),
              SizedBox(height: 20,),
              /*
              Text('Крайний срок:', textScaleFactor: 1.1,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: Icon(Icons.fast_rewind), color: Colors.blueAccent,
                    onPressed: (){
                      setState(() {
                        dtDeadline = dtDeadline.add(const Duration(days: -1));
                      });
                    },
                  ),
                  Text(MyServices.dateRus(dtDeadline), textScaleFactor: 1.4, style: TextStyle(color: Colors.blue),),
                  //IconButton(icon: Icon(Icons.edit), onPressed: (){_selectDate(context);}),
                  IconButton(icon: Icon(Icons.fast_forward), color: Colors.blueAccent,
                    onPressed: (){
                      setState(() {
                        dtDeadline = dtDeadline.add(const Duration(days: 1));
                      });
                    },
                  ),
              ],),

               */
              SizedBox(height: 14,),
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[400],
                child: Text('Фото', textScaleFactor: 1.1, textAlign: TextAlign.center,)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: _chooseImageFromCamera,
                    child: Text(MyServices.msgs['Сфотографировать'][widget.lang]),
                  ),
                  SizedBox(width: 14),
                  RaisedButton(
                    onPressed: _chooseImageFromGallery,
                    child: Text('Галерея'),
                  ),
                ],
              ),
              SizedBox(height: 15),
              filesList.length == 0? SizedBox()
              : Container(
                height: 150, width: double.infinity,
                child: Scrollbar(
                  isAlwaysShown: true,
                  controller: _sc,
                  child: ListView.builder(
                    controller: _sc,
                    scrollDirection: Axis.horizontal,
                    itemCount: filesList.length,
                    itemBuilder:  (BuildContext context, int index) {
                      int backIdx =  filesList.length - index - 1;
                      Image _img = Image.file(filesList[backIdx]);
                      return GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 150, width: 150,
                              child: _img,
                          )
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoView(_img)));
                        },
                      );
                    }
                  ),
                ),
              ),
              SizedBox(height: 15),

            ],
          ),
        ),
        floatingActionButton: Container(
          width: 80, height: 80,
          child: FittedBox(
            child: showProgressWhileSave?
              CircularProgressIndicator()
              :
              FloatingActionButton(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                heroTag: 'btnOk',
                onPressed: _addTaskCmd,
                tooltip: 'Подтвердить',
                child: Icon(Icons.done_rounded, size: 40,),//      bottomNavigationBar: Container(
              ),
          ),
        ),
    );
  }

  void _chooseImageFromCamera() async {
    file = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 2000, maxHeight: 2000);
    if (file == null) return;
    setState(() {
      filesList.add(file);
    });
  }

  void _chooseImageFromGallery() async {
    file = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 2000, maxHeight: 2000);
    if (file == null) return;
    setState(() {
      filesList.add(file);
    });
  }

  void _addTaskCmd() {
    if (_selectedLesson == '' || _selectedLesson == '...') {
      MyServices.showAlertPage(context, 'Выберите урок');
      return;
    }
    String _homeTaskDetails = _textEditingController.text.trim();
    if (_homeTaskDetails == '') {
      MyServices.showAlertPage(context, 'Укажите ДЗ');
      return;
    }
    print('add task OK with $_homeTaskDetails and deadline $dtDeadline');
    DateTime _dtStart = DateTime.now();
    HomeTask newTask = HomeTask(_homeTaskDetails, [], _dtStart, dtDeadline, _selectedLesson);
    newTask.city = widget.city;
    newTask.school = widget.school;
    newTask.teacher = widget.teacher;
    newTask.classRoom = widget.classRoom;

    setState(() {
      showProgressWhileSave = true;
    });

    MyServices.addNewTask(newTask)
    .then((value) async {
      List<String> lv = value.body.toString().split(' ');
      if (lv[0]=='OK') {
        newTask.id = lv[1];
        print('got new task id ${newTask.id}');
        await uploadTaskImages(newTask);
        Navigator.pop(context, newTask);
      } else {
        MyServices.showAlertPage(context, 'Ошибка. ${value.body}');
        setState(() {
          showProgressWhileSave = false;
        });
      }
    });
  }

  uploadTaskImages(newTask) async {
    print('uploading new task images');
    for (int i=0; i < filesList.length; i++) {
      file = filesList[i];
      await MyServices.uploadImage(newTask, file);
      print('uplading $i as $file');
    }
    print('has got uploading new task images');
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _sc.dispose();
    super.dispose();
  }
}
