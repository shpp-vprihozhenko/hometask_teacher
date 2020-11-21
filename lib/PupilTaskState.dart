class PupilTaskState {
  String pupilId;
  String state;

  PupilTaskState(this.pupilId, this.state);

  @override
  String toString() {
    return '{ pupilId: $pupilId, state: $state }';
  }
}
