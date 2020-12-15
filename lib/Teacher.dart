class Teacher{
  String id;
  String fio;
  String city;
  String school;
  String classRoom;
  String ownerId, pwd;
  Teacher(this.fio, this.city, this.school, this.classRoom, {this.ownerId, this.pwd});

  @override
  String toString() {
    return 'teacher: id $id fio $fio from $city $school $classRoom ownerId $ownerId pwd $pwd';
  }
}