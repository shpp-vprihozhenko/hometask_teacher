import 'package:flutter/material.dart';
import 'Services.dart' as MyServices;
import 'HomeTask.dart';

class ShowArchive extends StatefulWidget {
  final String city, school, teacher, classRoom;
  final int lang;
  ShowArchive(this.city, this.school, this.teacher, this.classRoom, this.lang);

  @override
  _ShowArchiveState createState() => _ShowArchiveState();
}

class _ShowArchiveState extends State<ShowArchive> {
  final List <HomeTask> homeTasks = [];

  @override
  void initState() {
    _getArcHomeTasks();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classRoom),
      ),
      body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(MyServices.msgs['Архив ДЗ'][widget.lang], textScaleFactor: 2,),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                    itemCount: homeTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                          onTap: (){_openTask(index);},
                          child: ListTile(
                            tileColor: index%2 == 1? Colors.white : Colors.grey[200],
                            //leading: Text(homeTasks[index].lesson),
                            title: Text(homeTasks[index].lesson+': '+homeTasks[index].fullDescription),
                            subtitle: Text(homeTasks[index].dtStart.toString().substring(0,10)+' - '+homeTasks[index].dtDeadline.toString().substring(0,10)),
                            trailing: ClipOval(
                              child: Container(
                                color: Colors.lightBlue[200],
                                child: IconButton(
                                  iconSize: 20,
                                  color: Colors.deepPurple,
                                  icon: Icon(Icons.undo_rounded),
                                  onPressed:(){
                                    _moveFromArchive(index);
                                  },
                                ),
                              ),
                            ),
                          )
                      );
                    },
                  ),
                ),)
            ],
          )
      ),
    );
  }

  _getArcHomeTasks(){
    MyServices.getHomeTasks(homeTasks, widget.city, widget.school, widget.teacher, widget.classRoom, true)
        .then((value) {
      setState((){});
    });
    print('update homeTasks list ${homeTasks.length}');
  }

  _moveFromArchive(index){
    MyServices.askYesNo(context, 'Перести обратно из архива?', widget.lang)
        .then((value){
      print('got val on ask $value');
      if (value == null || value == false) return;
      MyServices.archTask(homeTasks[index], false)
      .then((res){
        print('got res on unarch $res');
        if (res != 'OK') {
          MyServices.showAlertPage(context, res);
        } else {
          homeTasks.removeWhere((item) => item.id == homeTasks[index].id);
          setState((){});
        }
      });
    });
  }

  _openTask(index){
    //TODO
  }
}
