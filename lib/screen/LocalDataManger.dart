import '../DataBase/Mongodb.dart';

class LocalDataManager {
  List<Map<String, dynamic>> logins = [];
  Map<String, dynamic> user_info = {};

  // Upload Data
  Future<void> loadlogins() async {
    try {
      final result = await MongoDatabase.get_users();
      logins = result;
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Map<String, dynamic> set_user(dynamic id) {
    for (Map<String, dynamic> user in logins) {
      if (user['id'] == id) {
        user_info = user;
        return user;
      }
    }
    print("Login Data Not set");
    return {};
  }

  Future<List<String>> get_position(String position) async {
    var uniquePositions = <String>{};
    for (var entry in await MongoDatabase.get_position(position)) {
      if (entry['head'] == position) uniquePositions.add(entry['position'] as String);
    }
    return uniquePositions.toList();
  }

  bool loginCheck(dynamic name, dynamic id) {
    if (logins.isNotEmpty) {
      for (Map<String, dynamic> user in logins) {
        print(user['name'] == name);
        if (user['id'] == id && user['name'] == name) {
          return true;
        }
      }
    } else {
      print("Login data from Database is empty");
    }
    return false;
  }

  Future<List<List<Map<String, dynamic>>>> get_Emp_Detail(dynamic position) async {
    DateTime date = DateTime.now();
    List<Map<String, dynamic>> Filled = <Map<String, dynamic>>[];
    List<Map<String, dynamic>> NotFilled = <Map<String, dynamic>>[];
    List<List<Map<String, dynamic>>> arr = <List<Map<String, dynamic>>>[];
    List<String> entered = await get_filled(date);

    for (Map<String, dynamic> emp in await MongoDatabase.get_Emp_Detail(position)) {
      if (position == emp['position'] && emp['delete']!="true") {
        if (entered.contains(emp['id'])) {
          Filled.add(emp);
        } else {
          NotFilled.add(emp);
        }
      }
    }
    arr.add(Filled);
    arr.add(NotFilled);

    return arr;
  }

  Future<List<String>> get_filled(DateTime date) async {
    List<Map<String, dynamic>> arr = await MongoDatabase.get_ans(date);
    List<String> empid = <String>[];

    for (Map<String, dynamic> i in arr) {
      empid.add(i['id']);
    }

    return empid;
  }

  Future<List<List<String>>> get_questions(dynamic position) async {
    List<Map<String, dynamic>> ques1 = await MongoDatabase.get_questions_position(position.toString());
    Map<String, dynamic> question = ques1[0];
    List<List<String>> arr = [];
    List<String> ques = <String>[];
    List<String> points = <String>[];
    for (int i = 0; i < question.length - 2; i++) {
      String temp = question[i.toString()].toString();
      String formatques = temp.substring(0, temp.length - 2);
      String fetchpoint = temp.substring(temp.length - 2, temp.length);
      ques.add(formatques);
      points.add(fetchpoint);
    }
    arr.add(ques);
    arr.add(points);
    return arr;
  }

  void insertanswerscollection(String id, String answers, String value, DateTime date,String position) async {
    await MongoDatabase.insertanswers(id, answers, value, date,position);
    print("Successfully uploaded");
  }

  Future<List<Map<String, dynamic>>> today_entry(String position, DateTime date) async {
    List<Map<String, dynamic>> arr = await MongoDatabase.fetch_todat(position, date);
    
    for(Map<String, dynamic> j in arr){
      List<int> res = <int>[];
      String ans = j["answers"].toString();
      for (int i = 0; i < ans.length; i += 2) {
        res.add(int.parse(ans[i]));
      }
      j["answers"]=res;
    }
    return arr;
  }
}
