abstract class ApiDetails {
  String get apiLink;
}

class MyApiDetails extends ApiDetails {
  @override
  String get apiLink => "http://192.168.61.238:3000";
}
