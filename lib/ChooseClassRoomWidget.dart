import 'package:flutter/material.dart';

class ChooseClassRoomWidget extends StatefulWidget {
  final classRoom;
  final int lang;
  ChooseClassRoomWidget(this.classRoom, this.lang);

  @override
  _ChooseClassRoomWidgetState createState() => _ChooseClassRoomWidgetState();
}

class _ChooseClassRoomWidgetState extends State<ChooseClassRoomWidget> {
  int classLevel = 0;
  List<String> classLetters = ['А','Б','В','Г','Д','Е','Ж','З','И','К'];
  int classLetterNumber = 0;

  @override
  void initState() {
    if (widget.lang == 1) {
      classLetters = ['А','Б','В','Г','Д','Е','Є','Ж','З','И','І','Ї','К'];
    }
    classLevel = int.parse(widget.classRoom.substring(0,1));
    classLetterNumber = classLetters.indexOf(widget.classRoom.substring(1,2));
    if (classLetterNumber==-1) classLetterNumber = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Column(
        children: [
          Text("Выберите класс:"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Text('Твой класс:',textScaleFactor: 1.5,),
              Column(children: [
                IconButton(icon: Icon(Icons.keyboard_arrow_up), onPressed: (){
                  if (classLevel<11)
                    classLevel++;
                  setState(() {});
                }),
                Text(classLevel.toString(), textScaleFactor: 2, style: TextStyle(color: Colors.blue),),
                IconButton(icon: Icon(Icons.keyboard_arrow_down), onPressed: (){
                  if (classLevel>1)
                    classLevel--;
                  setState(() {});
                }),
              ],),
              Column(children: [
                IconButton(icon: Icon(Icons.keyboard_arrow_up), onPressed: (){
                  if (classLetterNumber<classLetters.length)
                    classLetterNumber++;
                  setState(() {});
                }),
                Text(classLetters[classLetterNumber], textScaleFactor: 2, style: TextStyle(color: Colors.blue)),
                IconButton(icon: Icon(Icons.keyboard_arrow_down), onPressed: (){
                  if (classLetterNumber>0)
                    classLetterNumber--;
                  setState(() {});
                }),
              ],),
              SizedBox(width: 20),
              FloatingActionButton(
                  onPressed: (){
                    String classRoom = '$classLevel'+classLetters[classLetterNumber];
                    Navigator.pop(context, classRoom);
                  },
                  child: Icon(Icons.done)),
            ],),
        ],
      ),
    );
  }
}
