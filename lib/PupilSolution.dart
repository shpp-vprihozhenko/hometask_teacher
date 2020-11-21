class PupilSolution {
  String id, taskId, pupilId;
  List<String> files;
  String status, mark;

  PupilSolution(this.id, this.taskId, this.pupilId, this.files, this.status, this.mark);

  @override
  String toString() {
    return 'sol id $id, taskId $taskId, pupilId $pupilId, files $files, status $status, mark $mark';
  }
}