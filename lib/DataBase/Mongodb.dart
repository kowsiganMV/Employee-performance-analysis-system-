import 'dart:developer';
import 'dart:ffi';
import 'package:app/DataBase/MongoDBModel.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'const.dart';
import 'AnswerModel.dart';

class MongoDatabase {
  static var db,collection,data_collection,questions_collection,answers_collection,decices_collection,com_use;
  static connect() async{
    db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    collection = db.collection(COLLECTION_NAME);
    data_collection=db.collection(DATA_COLLECTION);
    questions_collection=db.collection(QUESTION_COLLECTION);
    answers_collection=db.collection(ANSWER_COLLECTION);
    decices_collection=db.collection(DEVICES_COLLECTION);
    com_use=db.collection(COM_USE);
    print(status);
  }

  static Future<List<Map<String,dynamic>>> get_users() async{
    final arr=await collection.find().toList();
    return arr;
  }

  static Future<bool> get_devices(String dev_id) async{
    final arr = await decices_collection.find(where.eq('id', dev_id)).toList();
    if(arr.isEmpty==false)
    return true;
    return false;
  }

  static Future<String> Insert(MongoDbModel data) async{
    try{
      var result=await data_collection.insertOne(data.toJson());
      if(result.isSuccess) 
      return "Data Inserted";
      else
      return "**Data Not Inserted**";
    }catch(e){
      print(e.toString());
      return e.toString();
    }
  }
  static Future<void> insertanswers(String id, String answers, String value, DateTime date,String position) async {
      final data = Answersmodel(
        id: id,
        answers: answers,
        date: date, 
        total: value,
        position: position
      );

      try {
        var result = await answers_collection.insertOne(data.toJson());
        if (result.isSuccess) {
          print("Data Inserted");
        } else {
          print("**Data Not Inserted**");
        }
      } catch (e) {
        print(e.toString());
      }
    }

    static Future<List<Map<String, dynamic>>> get_ans(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    
    final arr = await answers_collection.find(
      where.gte('date', startOfDay).lte('date', endOfDay)
    ).toList();
    
    return arr;
  }
  static Future<List<Map<String, dynamic>>> get_Emp_Detail(String position) async {
    final arr = await data_collection.find(where.eq('position', position)).toList();
    return arr;
  }



  static Future<List<Map<String, dynamic>>> get_position(String position) async {
    final arr = await data_collection.find(where.eq('head', position)).toList();
    return arr;
  }
  static Future<List<Map<String, dynamic>>> get_questions_position(String position) async {
    final arr = await questions_collection.find(where.eq('position', position)).toList();
    return arr;
  }

  static Future<List<Map<String, dynamic>>> get_analysis(String id, DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0); 

    final arr = await answers_collection
        .find(where.eq('id', id).gte('date', startOfMonth).lte('date', endOfMonth))
        .toList();

    arr.sort((a, b) {
      DateTime dateA = a['date'] as DateTime;
      DateTime dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });

    return arr;
  }


  static Future<bool> check_ans(String id, DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);

    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final arr = await answers_collection
        .find(where.eq('id', id).gte('date', startOfDay).lte('date', endOfDay))
        .toList();

    return arr.isNotEmpty;
  }
  static Future<List<Map<String, dynamic>>> fetch_todat(String position, DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);

    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final arr = await answers_collection
        .find(where.eq('position', position).gte('date', startOfDay).lte('date', endOfDay))
        .toList();

    return arr;
  }

  static Future<Map<String, dynamic>?> findAndUpdate(String id, DateTime date, String answers, String value,String position) async {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      var filter = where
          .eq('id', id)
          .gte('date', startOfDay)
          .lte('date', endOfDay);

      var update = {
        r'$set': {
          'answers': answers,
          'total': value,
          'date': date,
          'position':position,
        }
      };

      await answers_collection.update(
        filter,
        update,
        upsert: true,
      );
      final updatedDocument = await answers_collection.findOne(filter);
      print("UPDATED");

      return updatedDocument;
  }

  //Common datas
  static Future<List<String>> get_Com(String access) async {
    final arr = await com_use.find(where.eq('access', access)).toList();
    List<String> res=<String>[];
    for(int i=0;i<arr[0].length-2;i++){
      res.add(arr[0][i.toString()]);
    }
    return res;
  }
  static Future<Map<String,dynamic>> get_img(String access) async {
    final arr = await com_use.findOne(where.eq('access', access));
    return arr;
  }

  static Future<List<Map<String, dynamic>>> get_past_Emp() async {
    final arr = await data_collection.find(where.eq('delete', "true")).toList();
    return arr;
  }

  static Future<Map<String, dynamic>?> deleteEmployee(Map<String, dynamic> data) async {
      

      var filter = where.eq('id', data['id']);

      var update = {
        r'$set': {
          'id':data['id'],
          'name':data['name'],
          'position':data['position'],
          'head':data['head'],
          'image':data['image'],
          'delete':"true",
          'leave_date':DateTime.now().toString().split(" ")[0]
        }
      };

      await data_collection.update(
        filter,
        update,
        upsert: true,
      );
      final updatedDocument = await answers_collection.findOne(filter);
      print("UPDATED");

      return updatedDocument;
  }

  //Past report
  static Future<List<Map<String, dynamic>>> get_Past_Report(String id, int page) async {
      int pageSize = 20;  // Number of records per page
      int skip = (page - 1) * pageSize;  // Calculate the offset

      // Fetch data for the given id, sort by date in descending order, and apply pagination
      final arr = await answers_collection
          .find(where.eq('id', id)
                .sortBy('date', descending: true)
                .skip(skip)   // Skip the first 'skip' documents
                .limit(pageSize))  // Limit the result to 'pageSize' documents
          .toList();

      return arr;
    }

    static Future<List<double>> get_mark(String id) async {
  List<double> res = [];
  
  // Fetching the data asynchronously
  final arr = await answers_collection.find(where.eq('id', id)).toList();
  
  double sum = 0;
  
  for (int i = 0; i < arr.length; i++) {
    // Ensure safe type casting and handling unexpected types
    sum +=double.parse(arr[i]['total']);
  }
  
  // Add the length of the array (number of answers) and the sum of totals
  res.add((arr.length*10).toDouble()); // Converting to double for consistency
  res.add(sum);
  
  
  return res;
}



}