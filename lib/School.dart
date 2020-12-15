class School {
  String id, name, city;
  School(this.id, this.name, this.city);

  @override
  String toString() {
    return 'school: $id $name city $city';
  }
}
