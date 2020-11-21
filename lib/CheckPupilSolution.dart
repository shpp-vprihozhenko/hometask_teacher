import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:school_tasker_teacher/PupilSolution.dart';
import 'Services.dart' as MyServices;
import 'ZoomableImage.dart';

class CheckPupilSolution extends StatefulWidget {
  final PupilSolution pupilSolution;

  CheckPupilSolution(this.pupilSolution);

  @override
  _CheckPupilSolutionState createState() => _CheckPupilSolutionState();
}

class _CheckPupilSolutionState extends State<CheckPupilSolution> {
  int mark = 10;
  List<Widget> imgList = [];
  List<Uint8List> imgBytes = [];
  List<String> imgNames = [];

  @override
  void initState() {
    super.initState();
    loadSol();
  }

  loadSol() async {
    await MyServices.getPupilSolution(widget.pupilSolution);
    if (widget.pupilSolution.mark != null) {
      print('try parse ${widget.pupilSolution.mark}');
      try {
        mark = int.parse(widget.pupilSolution.mark);
        setState(() {});
      } catch(e) {}
    }
    if (widget.pupilSolution.files.length > 0) {
      imgList.clear();
      for (int i=0; i < widget.pupilSolution.files.length; i++ ){
        String fileName = widget.pupilSolution.files[i];

        imgList.add(CircularProgressIndicator());
        setState(() {});

        Uint8List bytes = await MyServices.loadImageFromServer(fileName, mode: 'solution', resulType: 'ImageBytes');

        imgNames.add(fileName);
        imgBytes.add(bytes);
        imgList.last = Image.memory(bytes);

        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Проверка ДЗ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Оценка:', textScaleFactor: 1.2,),
                IconButton(icon: Icon(Icons.fast_rewind), color: Colors.blueAccent,
                  onPressed: (){
                    setState(() {
                      if (mark>1)
                        mark--;
                    });
                  },
                ),
                Text(mark.toString(), textScaleFactor: 1.6, style: TextStyle(color: Colors.blue),),
                IconButton(icon: Icon(Icons.fast_forward), color: Colors.blueAccent,
                  onPressed: (){
                    setState(() {
                      if (mark<12)
                        mark++;
                    });
                  },
                ),
              ],),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(4),
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(child: Text('Решение ученика:', textScaleFactor: 1.2,)),
                  IconButton(icon: Icon(Icons.refresh), onPressed: loadSol),
                ],
              )
            ),
            imgList.length == 0? SizedBox()
                : Expanded(
                    child: GridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width>500? 3 : 2,
                        children: List.generate(imgList.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              child: imgList[index],
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                  Scaffold(body: ZoomableImage(imgBytes[index]))
                                ))
                                .then((value) async {
                                  if (value == null) return;
                                  if (value['status']=='ok'){
                                    imgBytes[index] = value['bytes'];
                                    imgList[index] = Image.memory(value['bytes']);
                                    setState(() {});
                                    print('here need to update img on server side... ${imgNames[index]}');
                                    MyServices.updateImage(value['bytes'], imgNames[index], "solution")
                                    .then((value){
                                      if (value == 'OK') {
                                        MyServices.showAlertPage(context, 'Обновил');
                                      } else {
                                        MyServices.showAlertPage(context, 'Не смог обновить фото на сервере.\r\n$value');
                                      }
                                    });
                                  }
                                });
                              },
                            ),
                          );
                        })
                      )
                ),
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
            onPressed: _saveCheckCmd,
            tooltip: 'Подтвердить',
            child: Icon(Icons.done_rounded, size: 40,),//      bottomNavigationBar: Container(
          ),
        ),
      ),
    );
  }

  _saveCheckCmd() async {
    bool answer = await MyServices.askYesNo(context, 'Вы хотите поставить оценку $mark?');
    if (answer == null || answer == false) {
      return;
    }
    bool result = await MyServices.markPupilSolution(widget.pupilSolution, mark, context);
    if (result == null || result == false) {
      return;
    }
    Navigator.pop(context, mark);
  }
}
