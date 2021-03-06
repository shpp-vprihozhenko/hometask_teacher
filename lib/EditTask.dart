import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'PhotoView.dart';
import 'Services.dart' as MyServices;

class EditTask extends StatefulWidget {
  final taskToEdit, classRoom, city, school, teacher;
  final int lang;

  EditTask(this.taskToEdit, this.classRoom, this.city, this.school, this.teacher, this.lang);

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _sc = ScrollController();
  String _selectedLesson = '';
  DateTime dtDeadline;
  List <Widget> filesList = [];
  bool showProgressIndicator = false;
  List <DropdownMenuItem<String>> lessonsDDI = [];

  @override
  void initState() {
    dtDeadline = widget.taskToEdit.dtDeadline;
    _textEditingController.text = widget.taskToEdit.fullDescription;
    _selectedLesson = widget.taskToEdit.lesson;
    loadLessonsDDI();
    loadImages();
    super.initState();
  }

  loadLessonsDDI() {
    lessonsDDI.add(
        DropdownMenuItem(
          value: widget.taskToEdit.lesson,
          child: new Text(widget.taskToEdit.lesson, style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
        )
    );
    MyServices.getLessons()
        .then((value){
      if (value == null) return;
      value.forEach((el){
        if (el == widget.taskToEdit.lesson) return;
        print('add to ddm $el');
        lessonsDDI.add(DropdownMenuItem(
          value: el,
          child: new Text(el, style: TextStyle(color: Colors.blue), textScaleFactor: 1.1,),
        ));
      });
      setState(() {});
    });
  }

  loadImages() {
    MyServices.getTaskImagesList(widget.taskToEdit.id)
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
    widget.taskToEdit.linksToPhotos.clear();
    filesList.add(CircularProgressIndicator());
    setState(() {});
    int curElemPos = filesList.length-1;
    print('got pos $curElemPos');
    MyServices.loadImageFromServer(fileName)
    .then((imageWidget){
      print('_loadImageFromServer with $imageWidget');
      if (imageWidget != null) {
        print('add to fileList $fileName');
        widget.taskToEdit.linksToPhotos.add(fileName);
        filesList[curElemPos] = imageWidget;
        print('place foto at $curElemPos');
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classRoom),
        //leading: IconButton(icon: Icon(Icons.refresh), onPressed: _doTest,),
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
                  onPressed: (){_addImageFrom('Camera');},
                  child: Text(MyServices.msgs['Сфотографировать'][widget.lang]),
                ),
                SizedBox(width: 14),
                RaisedButton(
                  onPressed: (){_addImageFrom('Gallery');},
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
                      return Stack(
                        children: [
                          GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: filesList[backIdx],
                            ),
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoView(filesList[backIdx])));
                            },
                          ),
                          Positioned(
                            bottom: 0, right:-25,
                            child: RawMaterialButton(
                              onPressed: () {_delImg(backIdx);},
                              elevation: 2.0,
                              fillColor: Colors.grey[200],
                              child: Icon(
                                Icons.delete_forever,
                                size: 30.0,
                              ),
                              padding: EdgeInsets.all(5.0),
                              shape: CircleBorder(),
                            )
                          ),
                        ],
                      );
                    }
                ),
              ),
            ),
            SizedBox(height: 100),

          ],
        ),
      ),
      floatingActionButton: Container(
        width: 80, height: 80,
        child: FittedBox(
          child: showProgressIndicator?
          CircularProgressIndicator() :
          FloatingActionButton(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            heroTag: 'btnOk',
            onPressed: _saveTaskCmd,
            tooltip: 'Подтвердить',
            child: Icon(Icons.done_rounded, size: 40,),//      bottomNavigationBar: Container(
          ),
        ),
      ),
    );
  }

  void _addImageFrom(source) async {
    File file;
    if (source=='Camera') {
      file = await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 2000, maxHeight: 2000);
    } else {
      file = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 2000, maxHeight: 2000);
    }
    if (file == null) return;

    MyServices.uploadImage(widget.taskToEdit, file);

    setState(() {
      filesList.add(Image.file(file));
    });
  }

  _saveTaskCmd(){
    print('save task.');
    widget.taskToEdit.dtDeadline = dtDeadline;
    widget.taskToEdit.fullDescription = _textEditingController.text;
    widget.taskToEdit.lesson = _selectedLesson;
    showProgressIndicator = true;
    setState(() {});
    MyServices.updateTask(widget.taskToEdit, widget.city, widget.school, widget.teacher, _selectedLesson)
    .then((value) {
      if (value.body.toString().substring(0,2)=='OK') {
        Navigator.pop(context, 'ok');
      } else {
        MyServices.showAlertPage(context, 'Ошибка. ${value.body}');
        showProgressIndicator = false;
        setState(() {});
      }
    });
  }

  _delImg(idx){
    print('del img ${widget.taskToEdit.linksToPhotos[idx]}');
    MyServices.askYesNo(context, "Точно удалять?", widget.lang)
    .then((resp){
      if (resp != null && resp == true) {
        MyServices.delImageFromServer(widget.taskToEdit.id, widget.taskToEdit.linksToPhotos[idx])
        .then((resp){
          if (resp == 'OK') {
            widget.taskToEdit.linksToPhotos.removeAt(idx);
            setState((){
              filesList.removeAt(idx);
            });
          } else {
            MyServices.showAlertPage(context, 'Что-то пошло не так. Повторите попозже.');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _sc.dispose();
    super.dispose();
  }
}
