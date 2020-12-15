import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_tasker_teacher/City.dart';
import 'package:school_tasker_teacher/Teacher.dart';
import 'HomeTask.dart';
import 'Pupil.dart';
import 'PupilSolution.dart';
import 'PupilTaskState.dart';
import 'School.dart';

final String nodeEndPoint = 'http://62.109.10.134:6613';
//final String nodeEndPoint = 'http://192.168.1.15:6613';
//final String nodeEndPoint = 'http://144.76.198.99:6613';

showAlertPage(context, String msg) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(msg),
        );
      }
  );
}

Future<dynamic> askYesNo(context, String msg, int lang) {
  final c = new Completer();
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(msg),
          actions: [
            FlatButton(
              child: Text(lang == 0? 'Да':'Так'),
              onPressed: (){
                c.complete(true);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(lang == 0? 'Нет':'Ні'),
              onPressed: (){
                c.complete(false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
  );
  return c.future;
}

Future <void> getTeachers (List <Teacher> teachers, String city, String school, String teacherId) async {
  teachers.clear();
  var result = await http.post(nodeEndPoint+'/getTeachers',
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
    body: jsonEncode(
        <String, dynamic>{
          'city': city,
          'school': school,
          'ownerId': teacherId,
        }
    ),
  );
  if (result.statusCode == 200) {
    print('got result on getTeachers ${result.body}');
    try {
      var jResult = jsonDecode(result.body);
      var listL = jResult["ar"];
      if (listL.length > 0) {
        listL.forEach((el){
          teachers.add(Teacher(el["fio"], el["city"], el["school"], el["classRoom"], ownerId: el["ownerId"], pwd: el["pwd"]));
        });
      }
      print('got Teachers $teachers');
    } catch(e) {
      print('got err on parse $e');
    }
  }
}

Future <String> addTeacher (Teacher newTeacher, context) async {
  print('addTeacher $newTeacher');
  var resp = await http.post(nodeEndPoint+'/addTeacher',
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
    body: jsonEncode(
        <String, dynamic>{
          'city': newTeacher.city,
          'school': newTeacher.school,
          'fio': newTeacher.fio,
          'pwd': newTeacher.pwd,
          'ownerId': newTeacher.ownerId,
        }
    ),
  );
  if (resp.body == null || resp.body.substring(0,2) != 'OK') {
    showAlertPage(context, 'Ошибка при добавлении. Попробуйте позже. \n${resp.body}');
    return null;
  }
  return resp.body.split(' ')[1];
}

Future <String> updateTeacher(Teacher teacher, String newPwd, context) async {
  print('updateTeacher $teacher for pwd $newPwd');
  var resp = await http.post(nodeEndPoint+'/updateTeacher',
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
    body: jsonEncode(
        <String, dynamic>{
          'city': teacher.city,
          'school': teacher.school,
          'fio': teacher.fio,
          'pwd': newPwd,
        }
    ),
  );
  if (resp.body == null || resp.body.substring(0,2) != 'OK') {
    showAlertPage(context, 'Ошибка при добавлении. Попробуйте позже. \n${resp.body}');
    return null;
  }
  return 'OK';
}

Future <String> addLesson (String lessonName, context) async {
  print('addLesson $lessonName');
  var resp = await http.post(nodeEndPoint+'/addLesson',
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
    body: jsonEncode(
        <String, dynamic>{
          'lesson': lessonName,
        }
    ),
  );
  if (resp.body == null || resp.body.substring(0,2) != 'OK') {
    showAlertPage(context, 'Ошибка при добавлении. Попробуйте позже. \n${resp.body}');
    return null;
  }
  return lessonName;
}

Future <List <String>> getLessons () async {
  List <String> l = ['Математика', 'Русский язык', 'Украинский язык', 'Чтение', 'Английский язык', 'Физкультура', ''];
  var result = await http.post(nodeEndPoint+'/getLessons');
  if (result.body != null) {
    print('got result on getLessons ${result.body}');
    try {
      var jResult = jsonDecode(result.body);
      var listL = jResult["ar"];
      if (listL.length > 0) {
        l.clear();
        listL.forEach((el){
          l.add(el["lesson"]);
        });
      }
    } catch(e) {
      print('got err on parse $e');
    }
  }
  print('got lessons $l');
  return l;
}

Future<dynamic> addNewTask(HomeTask task) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/add_task');
  http.post(nodeEndPoint+'/add_task',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          'lesson': task.lesson,
          'taskDescription': task.fullDescription,
          'dtStart': task.dtStart.toIso8601String(),
          'dtDeadline': task.dtDeadline.toIso8601String(),
          'city': task.city,
          'school': task.school,
          'teacher': task.teacher,
          'classRoom': task.classRoom,
        }
    ),
  ).then((value) {
    c.complete(value);
  });
  return c.future;
}

Future<dynamic> updateTask(taskToEdit, city, school, teacher, lesson){
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/update_task');
  http.post(nodeEndPoint+'/update_task',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          '_id': taskToEdit.id,
          'lesson': lesson,
          'taskDescription': taskToEdit.fullDescription,
          'dtStart': taskToEdit.dtStart.toIso8601String(),
          'dtDeadline': taskToEdit.dtDeadline.toIso8601String(),
          'city': city,
          'school': school,
          'teacher': teacher,
        }
    ),
  ).then((value) {
    c.complete(value);
  });
  return c.future;
}

Future<dynamic> getHomeTasks(List<HomeTask> homeTasks, String city, String school, String teacher, String classRoom, bool arcMode) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/hometasks'+'with $classRoom $arcMode');
  http.post(nodeEndPoint+'/hometasks',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          'city': city,
          'school': school,
          'teacher': teacher,
          'classRoom': classRoom,
          'filter': arcMode? 'archiveOnly' : 'activeOnly',
        }
    ),
  ).then((value) {
    var res = jsonDecode(value.body);
    if (res["err"] != null) {
      print('some err at get tasks cb(');
      c.complete('err ${res["err"]}');
    } else {
      print('got decoded ar ${res["ar"]}');
      homeTasks.clear();
      res["ar"].forEach((el){
        print('add $el');
        String t = '', l = '';
        DateTime dts = DateTime.now();
        DateTime dtd = DateTime.now();
        try {
          t = el["taskDescription"]; if (t == null) t='-';
          try { dts = DateTime.parse(el["dtStart"]); } catch(e) {}
          try { dtd = DateTime.parse(el["dtDeadline"]); } catch(e) {}
          l = el["lesson"]; if (l == null) l='-';
          print('id ${el["_id"]}');
        } catch(e) {
          print('got err $e');
          return;
        }

        HomeTask newTask = HomeTask(t, [], dts, dtd, l);
        newTask.id = el["_id"];
        newTask.city = city;
        newTask.school = school;
        newTask.teacher = teacher;
        newTask.classRoom = classRoom;

        homeTasks.add(newTask);
      });
      c.complete('ok');
    }
  });
  return c.future;
}

Future<dynamic> archTask (HomeTask homeTask, bool mode) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/arch_task');
  http.post(nodeEndPoint+'/arch_task',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          'id': homeTask.id,
          'mode': mode
        }
    ),
  ).then((value) {
    c.complete(value.body);
  });
  return c.future;
}

String dateRus(DateTime dt, [programLanguage = 0]) {
  List <String> _monthes = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
  if (programLanguage == 1) {
    _monthes = ['січня', 'лютого', 'березня', 'квітня', 'травня', 'червня', 'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня'];
  }
  return '${dt.day} ${_monthes[dt.month-1]} ${dt.year}';
}

Future<dynamic> uploadImage(task, file) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/uploadImage');
  String base64Image = base64Encode(file.readAsBytesSync());
  String fileName = '${task.city}_${task.school}_${task.teacher}_${task.classRoom}_${task.id}_${file.path.split("/").last}';
  print('fn '+fileName);

  http.post(nodeEndPoint+'/uploadImage',
    body: {
      "id": task.id,
      "image": base64Image,
      "name": fileName,
    },
  ).then((value) {
    c.complete(value.body);
  });

  return c.future;
}

Future<dynamic> updateImage(Uint8List imgBytes, String fileName, String type) async {
  print('send req to '+nodeEndPoint+'/updateImage for type $type');

  String base64Image = base64Encode(imgBytes);
  print('fn '+fileName+' length ${base64Image.length}');

  var result = await http.post(nodeEndPoint+'/updateImage',
    body: {
      "image": base64Image,
      "name": fileName,
      "type": type
    },
  );
  print('ok, img sent');

  return result.body;
}

Future<dynamic> getTaskImagesList(id) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/loadImagesList');
  http.post(nodeEndPoint+'/loadImagesList',
    body: {
      "id": id,
    },
  ).then((value) {
    try {
      var jData = jsonDecode(value.body);
      if (jData["err"] != null) {
        c.complete([]);
      } else {
        c.complete(jData["arFiles"]);
      }
    } catch(e) {
      c.complete([]);
    }
  });
  return c.future;
}

loadImageFromServer(fileName, {String mode='task', String resulType='ImageWidget'}){
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/loadImage with $fileName $mode');
  http.post(nodeEndPoint+'/loadImage',
    body: {
      "fileName": fileName,
      "mode": mode
    },
  ).then((value) {
    try {
      Uint8List bytes = base64Decode(value.body);
      if (resulType == 'ImageWidget') {
        print('resolve get img as widget');
        Image imageWidget = Image.memory(bytes);
        c.complete(imageWidget);
      } else if (resulType == 'ImageBytes') {
        print('resolve get img as Uint8List bytes');
        c.complete(bytes);
      } else if (resulType == 'ImageProvider') {
        print('resolve get img as ImageProvider');
        c.complete(MemoryImage(bytes));
      }
    } catch(e) {
      print('got err $e');
      c.complete();
    }
  });

  return c.future;
}

delImageFromServer(taskId, fileName){
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/delImage');
  http.post(nodeEndPoint+'/delImage',
    body: {
      "id": taskId,
      "name": fileName,
    },
  ).then((value) {
    try {
      print('got on del ${value.body}');
      if (value.body=='OK') {
        c.complete('OK');
      } else {
        c.complete('err');
      }
    } catch(e) {
      print('got err $e');
      c.complete('err');
    }
  });
  return c.future;
}

// pupils

Future<dynamic> addPupil(Pupil pupil) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/add_pupil');
  http.post(nodeEndPoint+'/add_pupil',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          'city': pupil.city,
          'school': pupil.school,
          'classRoom': pupil.classRoom,
          'fio': pupil.fio,
          'password': pupil.password,
        }
    ),
  ).then((value) {
    if (value.body.substring(0,2)=='OK') {
      print('ok');
      String id = value.body.toString().split(' ')[1];
      pupil.id = id;
      c.complete(pupil);
    } else {
      c.complete();
    }
  });
  return c.future;
}

Future<dynamic> getPupilsList(List<Pupil> pupilsList, String city, String school, String classRoom) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/getPupils');
  http.post(nodeEndPoint+'/getPupils',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          'city': city,
          'school': school,
          'classRoom': classRoom,
        }
    ),
  ).then((value) {
    if (value.body == null) {
      print('some err at get pupils cb( No body');
      c.complete('err');
      return;
    }
    var res;
    try {
      res = jsonDecode(value.body);
      if (res["err"] != null) {
        print('some err on server side on pupils get');
        c.complete('err ${res["err"]}');
        return;
      }
    } catch (e) {
      print('some err on parse server\'s response on pupils get');
      c.complete('err $e');
      return;
    }
    print('got decoded ar ${res["ar"]}');
    pupilsList.clear();
    res["ar"].forEach((el) {
      print('add $el');
      //"_id":"","city":"","school":"","classRoom":"","fio":" kachanovv andry","password":"ы0ИнаЗ"}
      String id = '',
          fio = '',
          password = '';
      try {
        id = el["_id"];
      } catch (e) {
        print('got err in id $e');
      }
      try {
        fio = el["fio"];
      } catch (e) {
        print('got err on fio $e');
      }
      try {
        password = el["password"];
      } catch (e) {
        print('got err on password $e');
      }

      Pupil pupil = Pupil(id, city, school, classRoom, fio, password);
      pupilsList.add(pupil);
    });
    c.complete('ok');
  });
  return c.future;
}

Future<dynamic> editPupil(pupilId, fio, password) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/update_pupil');
  http.post(nodeEndPoint+'/update_pupil',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          '_id': pupilId,
          'fio': fio,
          'password': password,
        }
    ),
  ).then((value) {

    print('got ${value.body} on update req');

    if (value.body.substring(0,2)=='OK') {
      print('ok on update');
      c.complete('ok');
    } else {
      c.complete();
    }
  });
  return c.future;
}

// cities

Future<dynamic> addCity(String city) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/add_city');
  http.post(nodeEndPoint+'/add_city',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{
          'city': city,
        }
    ),
  ).then((value) {
    if (value.body.substring(0,2)=='OK') {
      print('ok');
      String id = value.body.toString().split(' ')[1];
      c.complete(id);
    } else {
      c.complete();
    }
  });
  return c.future;
}

Future<dynamic> getCitiesList(List<City> cities) {
  final c = new Completer();
  print('send req to '+nodeEndPoint+'/getCities');
  http.post(nodeEndPoint+'/getCities',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: ''
  ).then((value) {
    if (value.body == null) {
      print('some err at get pupils cb( No body');
      c.complete('err');
      return;
    }
    var res;
    try {
      res = jsonDecode(value.body);
      if (res["err"] != null) {
        print('some err on server side on pupils get');
        c.complete('err ${res["err"]}');
        return;
      }
    } catch (e) {
      print('some err on parse server\'s response on pupils get');
      c.complete('err $e');
      return;
    }
    print('got decoded ar ${res["ar"]}');
    cities.clear();
    res["ar"].forEach((el) {
      print('add $el');
      cities.add(City(el["_id"], el["city"]));
    });
    c.complete('ok');
  });
  return c.future;
}

fillPupilsTaskStateList(pupilsList, task, pupilTaskStateList) async {
  print('fillPupilsTaskStateList send req to '+nodeEndPoint+'/getPupilsTaskStates');

  var params = {};
  params["taskId"] = task.id;

  var value = await http.post(nodeEndPoint+'/getPupilsTaskStates',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(params),
  );

  if (value.body == null) {
    print('some err at get pupils cb( No body');
    return;
  }
  var res;
  try {
    res = jsonDecode(value.body);
    if (res["err"] != null) {
      print('some err on server side on pupils get');
      return;
    }
  } catch (e) {
    print('some err on parse server\'s response on pupils get');
    return;
  }

  print('got decoded ar ${res["ar"]}');

  pupilTaskStateList.clear();
  res["ar"].forEach((el) {
    print('add $el');
    pupilTaskStateList.add(PupilTaskState(el["pupilId"], el["status"].toString()));
  });

  print('fill pupilTaskStateList $pupilTaskStateList');
}

Future <void> getPupilSolution(PupilSolution pupilSolution) async {
  print('getPupilSolution send req to '+nodeEndPoint+'/getPupilSolvedTaskData');

  var params = {};
  params["taskId"] = pupilSolution.taskId;
  params["pupilId"] = pupilSolution.pupilId;

  var value = await http.post(nodeEndPoint+'/getPupilSolvedTaskData',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(params),
  );

  if (value.body == null) {
    print('some err at getPupilSolvedTaskData cb( No body');
    return;
  }

  var res;
  try {
    res = jsonDecode(value.body);
    if (res["err"] != null) {
      print('some err on server side on getPupilSolvedTaskData');
      return;
    }
  } catch (e) {
    print('some err on parse server\'s response on getPupilSolvedTaskData');
    return;
  }

  print('got decoded res $res');

  pupilSolution.id = res["data"]["_id"];
  pupilSolution.files.clear();
  res["data"]["files"].forEach((el){
    pupilSolution.files.add(el);
  });
  pupilSolution.status = '-';
  try {
    print('\n\ngot mark ${res["data"]["mark"]}');
    pupilSolution.mark = res["data"]["mark"].toString();
  } catch(e) {}

  print('update sol $pupilSolution');
}

Future <bool> markPupilSolution(PupilSolution pupilSolution, int mark, context) async {
  print('markPupilSolvedTask send req to '+nodeEndPoint+'/markPupilSolvedTask');

  var params = {};
  params["id"] = pupilSolution.id;
  params["mark"] = mark;

  var value = await http.post(nodeEndPoint+'/markPupilSolvedTask',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(params),
  );

  if (value.body == null) {
    print('some err at markPupilSolvedTaskData cb( No body');
    showAlertPage(context, 'Что-то пошло не так, не смог записать оценку на сервер.\nПопробуйте ещё раз позже.');
    return false;
  }

  var res = value.body;
  print('got res $res');

  if (res != 'OK') {
    showAlertPage(context, 'Что-то пошло не так, не смог записать оценку на сервер.\nПопробуйте ещё раз позже.');
    return false;
  }

  pupilSolution.mark = '$mark';
  print('ok mark sol $pupilSolution');
  return true;
}

Future <String> identifyTeacher(Teacher teacher, String pwd, context) async {
  print('send req to '+nodeEndPoint+'/checkTeacherPwd');
  var value = await http.post(
      nodeEndPoint+'/checkTeacherPwd',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, dynamic> {
            "city": teacher.city,
            "school": teacher.school,
            "fio": teacher.fio,
            "pwd": pwd
          })
  );

  if (value.body == null) {
    print('some err at get pupils cb( No body');
    showAlertPage(context, 'Нет ответа от сервера.');
    return '';
  }

  if (value.body.substring(0,2)=='OK') {
    print('check ok');
    return value.body.split(' ')[1];
  }

  showAlertPage(context, 'Получен неправильный ответ от сервера.');
  return '';
}

//---------------- schools -------------

Future <String> addSchool(String school, String city) async {
  print('send req to '+nodeEndPoint+'/addSchool');
  var value = await http.post(nodeEndPoint+'/addSchool',
    headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
    body: jsonEncode(
        <String, dynamic>{
          'city': city,
          'school': school
        }
    ),
  );
  if (value.body.substring(0,2)=='OK') {
    print('ok');
    String id = value.body.toString().split(' ')[1];
    return id;
  }
  return 'err '+value.body;
}

Future<List <School>> getSchools(String cityName) async {
  print('send req to '+nodeEndPoint+'/getSchools');
  var value = await http.post(nodeEndPoint+'/getSchools',
      headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
      body: jsonEncode(
        <String, dynamic>{
        'city': cityName,
      })
  );
  if (value.body == null) {
    print('some err at get schools cb( No body');
    return [];
  }
  var res;
  try {
    res = jsonDecode(value.body);
    if (res["err"] != null) {
      print('some err on server side on schools get');
      return [];
    }
  } catch (e) {
    print('some err on parse server\'s response on schools get');
    return [];
  }
  print('got decoded ar schools ${res["ar"]}');
  List <School> schools = [];
  res["ar"].forEach((el) {
    print('add $el');
    schools.add(School(el["_id"], el["school"], cityName));
  });
  return schools;
}

Future <String> updateSchool(String _id, String newSchoolName) async {
  print('send req to '+nodeEndPoint+'/updateSchool');
  var value = await http.post(nodeEndPoint+'/updateSchool',
    headers: <String, String>{ 'Content-Type': 'application/json; charset=UTF-8', },
    body: jsonEncode(
        <String, dynamic>{
          '_id': _id,
          'school': newSchoolName
        }
    ),
  );
  if (value.body == 'OK') {
    print('OK');
    return 'OK';
  }
  return 'err '+value.body;
}

//---------------- msgs -------------

Map <String, List<String>> msgs = {
  'Идентифицикация': ['Идентифицикация','Ідентифікація'],
  'Настройки': ['Настройки','Налаштування'],
  'Выданные ДЗ': ['Выданные ДЗ','ДЗ в роботі'],
  'Наши города': ['Наши города','Наші міста'],
  'Наши учителя': ['Наши учителя','Наші вчителі'],
  'Твой город: ': ['Твой город: ','Твоє місто: '],
  'Город': ['Город','Місто'],
  'Фамилия и имя': ['Фамилия и имя','Призвище та ім’я'],
  'Твой пароль': ['Твой пароль','Твій пароль'],
  'Укажите фамилию и имя': ['Укажите фамилию и имя','Вкажіть призвище та ім’я'],
  'Укажите пароль': ['Укажите пароль','Вкажіть пароль'],
  'Добавляем новый город': ['Добавляем новый город','Добавляємо нове місто'],
  'Введите название нового города': ['Введите название нового города','Вкажіть назву нового міста'],
  'Добавляем преподавателя': ['Добавляем преподавателя','Додаємо вчителя'],
  'ФИО преподавателя': ['ФИО преподавателя','Призвище та ім’я'],
  'Выберите город': ['Выберите город','Виберіть місто'],
  'Выберите школу': ['Выберите школу','Виберіть школу'],
  'В программу добавлены уроки:': ['В программу добавлены уроки:','В програму додані уроки:'],
  'Новый урок': ['Новый урок','Новий урок'],
  'Укажите название урока': ['Укажите название урока','Вкажіть назву урока'],
  'Мои ученики:': ['Мои ученики:','Мої учні:'],
  'Добавляем нового ученика': ['Добавляем нового ученика','Додаємо нового учня'],
  'Изменяем данные ученика': ['Изменяем данные ученика','Змінюємо дані про учня'],
  'Архив ДЗ': ['Архив ДЗ','Архів ДЗ'],
  'Разработчик: \nПрихоженко Владимир, \nvprihogenko@gmail.com': ['Разработчик: \nПрихоженко Владимир, \nvprihogenko@gmail.com','Розробник: \nПрихоженко Володимир, \nvprihogenko@gmail.com'],
  'Сфотографировать': ['Сфотографировать','Сфотографувати'],
  'Проверка': ['Проверка','Перевірка'],
  'Статус выполнения:': ['Статус выполнения:','Статус виконання:'],
  'Задача ещё не решена учеником': ['Задача ещё не решена учеником','Задача ще не вирішена учнем'],
  'Выдано: ': ['Выдано: ','Видано: '],
  'Задание': ['Задание','Завдання'],
  'Оценка:': ['Оценка:','Оцінка:'],
  'Решение ученика:': ['Решение ученика:','Рішення учня:'],
  'Вы хотите поставить оценку': ['Вы хотите поставить оценку','Ви бажаєте поставить оцінку'],
  'Перенести в архив?': ['Перенести ДЗ в архив?','Перенести ДЗ до архіву?'],
  'Наши школы': ['Наши школы','Наші школи'],
  'Перед добавлением школы выберите город': ['Перед добавлением школы выберите город','Перед додаванням школи вкажіть місто'],
  'Название школы': ['Название школы','Назва школи'],
  'Или выберите школу из списка:': ['Или выберите школу из списка:','Або виберіть школу зі списку:'],
};