import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../DataBase/Mongodb.dart';
import 'EmployeList.dart';
import 'package:intl/intl.dart';
import 'PastEmp.dart';

class PastReport extends StatefulWidget {
  final Map<String, dynamic> seniordata;
  final Map<String, dynamic> data;
  final String back;
  final DateTime lastDate;

  const PastReport({
    super.key, 
    required this.seniordata, 
    required this.data,
    this.back="",
    required this.lastDate,
  });

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState(seniordata: seniordata, data: data,back: back,lastDate: lastDate);
}

class _AnalysisScreenState extends State<PastReport> {
  final Map<String, dynamic> seniordata;
  final Map<String, dynamic> data;
  late List<int> days;
  late List<double> performanceData;
  List<Map<String, dynamic>> totans = [];
  DateTime? selectedDate;
  DateFormat formatter = DateFormat('MMMM');
  late String monthName;
  final String back;
  
  final DateTime lastDate;

  _AnalysisScreenState({
    required this.seniordata, 
    required this.data,
    this.back="",
    required this.lastDate
  });

  @override
  void initState() {
    super.initState();
    days = [];
    performanceData = [];
    _initialData();
  }

  Future<void> _initialData() async {
    totans=await MongoDatabase.get_Past_Report(widget.data['id'],2);
    print(totans);
  }

  @override
  Widget build(BuildContext context) {
   
    return (Text("Hello"));
  }
}
