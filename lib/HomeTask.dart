class HomeTask {
  String id;
  String fullDescription;
  List <String> linksToPhotos = [];
  DateTime dtStart;
  DateTime dtDeadline;
  String lesson;
  String city;
  String school;
  String teacher;
  String classRoom;

  HomeTask(this.fullDescription, this.linksToPhotos, this.dtStart, this.dtDeadline, this.lesson);
}
