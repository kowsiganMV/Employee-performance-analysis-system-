import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../DataBase/Mongodb.dart';
import 'EmployeList.dart';
import 'package:intl/intl.dart';
import 'PastEmp.dart';

class AnalysisScreen extends StatefulWidget {
  final Map<String, dynamic> seniordata;
  final Map<String, dynamic> data;
  final String back;
  final DateTime lastDate;

  const AnalysisScreen({
    super.key, 
    required this.seniordata, 
    required this.data,
    this.back="",
    required this.lastDate,
  });

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState(seniordata: seniordata, data: data,back: back,lastDate: lastDate);
}

class _AnalysisScreenState extends State<AnalysisScreen> {
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
    print("-----------DATEYYYYY");
    print(lastDate);
    totans = await MongoDatabase.get_analysis(widget.data['id'], DateTime.now());
    setState(() {
      days = totans.map((item) => (item['date'] as DateTime).day).toList();
      performanceData = totans.map((item) => double.parse(item['total'])).toList();
      monthName = formatter.format(DateTime.now());
    });
    if (totans.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.lightGreen[100], // Set the background color to light green
          actions: [
            Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  selectDate(context);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white, // Button background color
                  side: BorderSide(
                    color: Colors.green, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
          title: Center(
            child: const Text('No data found'),
          ),
          contentPadding: const EdgeInsets.all(20.0),
        ),
      );
    }
  }

  List<Color> gradientColors = [
    Color.fromARGB(255, 127, 164, 216),
    Color.fromARGB(255, 196, 212, 235),
  ];
Future<void> selectDate(BuildContext context) async {
  DateTime initialDate = DateTime.now();
  if (initialDate.isAfter(lastDate)) {
    initialDate = lastDate;
  }

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(DateTime.now().year, DateTime.august, 6),
    lastDate: lastDate, // Use the corrected lastDate
  );

  if (picked != null && picked != selectedDate) {
    setState(() {
      selectedDate = picked;
    });

    totans = await MongoDatabase.get_analysis(widget.data['id'], selectedDate ?? DateTime.now());
    
    setState(() {
      days = totans.map((item) => (item['date'] as DateTime).day).toList();
      performanceData = totans.map((item) => double.parse(item['total'])).toList();
      monthName = formatter.format(totans[0]['date']);
    });
    print("Running vro");
  }
}

  @override
  Widget build(BuildContext context) {
    if (performanceData.isEmpty) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromARGB(255, 237, 235, 235),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(172, 36, 174, 52),
            leading: BackButton(
              onPressed: () {
                if(back==""){
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EmpList(seniordata: seniordata, position: data['position']), // Navigate to EmpList
                      ),
                    );
                  }
                  else{
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Pastemp(seniordata: seniordata), // Navigate to EmpList
                      ),
                    );
                  }
              },
            ),
            title: Text('Analyze'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    double lowScore = performanceData.reduce((a, b) => a < b ? a : b).toDouble();
    double highScore = performanceData.reduce((a, b) => a > b ? a : b).toDouble();
    double averageScore = performanceData.reduce((a, b) => a + b) / performanceData.length;
    double totalScore = performanceData.reduce((a, b) => a + b).toDouble();

    return WillPopScope(
      onWillPop: () async {
        if(back==""){
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EmpList(seniordata: seniordata, position: data['position']), // Navigate to EmpList
                      ),
                    );
                  }
                  else{
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Pastemp(seniordata: seniordata), // Navigate to EmpList
                      ),
                    );
                  }
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color.fromARGB(255, 237, 235, 235),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(172, 36, 174, 52),
            leading: BackButton(
              onPressed: () {
                if(back==""){
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EmpList(seniordata: seniordata, position: data['position']), // Navigate to EmpList
                      ),
                    );
                  }
                  else{
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Pastemp(seniordata: seniordata), // Navigate to EmpList
                      ),
                    );
                  }
              },
            ),
            title: Text('Analyze'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: const Color.fromARGB(255, 39, 39, 39),
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Performance of $monthName",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => selectDate(context),
                  child: Text(selectedDate == null
                      ? 'Select Date'
                      : '${selectedDate!.toLocal()}'.split(' ')[0]),
                ),
                SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: AspectRatio(
                    aspectRatio: 3 / 2,
                    child: LineChart(
                      LineChartData(
                        maxX: 31, // Adjusted to 31 to include days from 1 to 30
                        maxY: 10,
                        minX: 1,
                        minY: 0,
                        gridData: FlGridData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(days.length,
                                (index) => FlSpot(days[index].toDouble(), performanceData[index].toDouble())),
                            isCurved: true,
                            dotData: FlDotData(show: true),
                            color: Color.fromARGB(255, 72, 127, 190), 
                            barWidth: 5,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text('Performance', style: TextStyle(color: Colors.black)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text('Days', style: TextStyle(color: Colors.black)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(value.toInt().toString(), style: TextStyle(color: Colors.black)),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            top: BorderSide.none,
                            right: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Color.fromARGB(255, 200, 220, 247),
                    child: Column(
                      children: [
                        Text(
                          '${widget.data['name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Nicholas',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(
                          height: 1,
                          color: Colors.black,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Low Score: $lowScore',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'High Score: $highScore',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                'Average Score: ${averageScore.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Total Score: ${totalScore.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
