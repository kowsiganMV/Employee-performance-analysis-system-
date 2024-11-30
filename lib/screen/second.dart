import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'EmployeList.dart';
import 'LocalDataManger.dart';
import 'ErrorWidget.dart';
import '../Appservices/connectivity_widget.dart';
import '../DataBase/Mongodb.dart';
import '../Appservices/Mail_process.dart';

class QuestionPage extends StatefulWidget {
  final Map<String, dynamic> seniordata;
  final Map<String, dynamic> data;
  final List<int> pre;

  const QuestionPage({
    Key? key,
    required this.seniordata,
    required this.data,
    required this.pre,
    
  }) : super(key: key);

  @override
  _QuestionState createState() => _QuestionState(
    seniordata: seniordata,
    data: data,
    pre: pre,
  );
}

class _QuestionState extends State<QuestionPage> {
  bool _isPresent = false;
  bool _showError = false;
  final Map<String, dynamic> seniordata;
  final Map<String, dynamic> data;
  final List<int> pre;

  LocalDataManager db = LocalDataManager();

  double value = 0;
  late DateTime time;
  late Future<List<String>> _questionsFuture;
  List<String> points=[];
  List<bool> _yesValues = List<bool>.filled(20, false);
  List<bool> _noValues = List<bool>.filled(20, false);

  _QuestionState({
    required this.seniordata,
    required this.data,
    required this.pre,
  });

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
    _questionsFuture = fetchQuestions();
    
    updateTime();
  }

  Future<List<String>> fetchQuestions() async {
    // Simulate fetching questions from a backend or database
    List<List<String>> questiondata=await  db.get_questions(data['position']);
    
    setState(() {
      points=questiondata[1];
    });
    if(!pre.isEmpty){
      // Initialize yes and no values based on the checklist
      for (int i = 0; i < pre.length; i++) {
        if (pre[i] == 1) {
          _yesValues[i] = true;
          _noValues[i] = false;
          value+=double.parse(points[i]);
        } else {
          _yesValues[i] = false;
          _noValues[i] = true;
        }
      }
    }
    print("Points"+points.length.toString());
    await Future.delayed(Duration(seconds: 2));
    return questiondata[0];
  }

  void updateTime() {
    setState(() {
      time = DateTime.now();
    });
    Future.delayed(Duration(seconds: 1), updateTime);
  }

  void onCheckboxChanged(int index, bool? newValue, bool isYes) {
    setState(() {
      if (isYes) {
        _yesValues[index] = newValue ?? false;
        if (_yesValues[index]) {
          _noValues[index] = false;
        }
      } else {
        _noValues[index] = newValue ?? false;
        if (_noValues[index]) {
          _yesValues[index] = false;
        }
      }
      double count=0.0;
      for(int i=0;i<_yesValues.length;i++){
        if(_yesValues[i]){
          count+=double.parse(points[i]);
        }
      }
      value =count;
    });
  }

  void handleSubmit() async{
    List<String> len=await _questionsFuture;
    String answers="";
    List<double> ans=<double>[];
    MailProcess mail =MailProcess();
    if(_isPresent){
      for(int i=0;i<len.length;i++){
        ans.add(0);
        answers+="0 ";
        setState(() {
          value=0.0;
          _yesValues = List<bool>.filled(20, false);
          _noValues = List<bool>.filled(20, false);
        });
      }
    }
    else{
      for (int i = 0; i < _yesValues.length; i++) {
        if (_yesValues[i]) {
          ans.add(1);
          answers+="1 ";
        } else if(_noValues[i]){
          answers+="0 ";
          ans.add(0);
        } 
      }
    }
    
    if(len.length==answers.length/2 ){//&& 
      if(await MongoDatabase.check_ans(data['id'], DateTime.now())==false){
        db.insertanswerscollection(data['id'], answers, value.toString(), DateTime.now(),data['position']);
        mail.individualEmail(len,[ans,[value]],data);
        showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.lightGreen[100], // Set the background color to light green
                  actions: [
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EmpList(seniordata: seniordata, position: data['position']), // Navigate to EmpList
                            ),
                          );
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
                  title: const Text('Updated Successfully'),
                  contentPadding: const EdgeInsets.all(20.0),
                ),
              );
        setState(() {
          _showError=false;
        });
      }
      else{
        //UPDATED CODE HERE
        print("Updation Start-----------");
        MongoDatabase.findAndUpdate(data['id'],DateTime.now(),answers,value.toString(),data['position']);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.lightGreen[100], // Set the background color to light green
            actions: [
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EmpList(seniordata: seniordata, position: data['position']), // Navigate to EmpList
                      ),
                    );
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
              child: const Text('Updated'),
            ),
            contentPadding: const EdgeInsets.all(20.0),
          ),
        );

      }
    }
    else{
      setState(() {
        _showError=true;
      });
    } // Do something with the collected answers
  }
  @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          // Handle the back navigation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmpList(
                seniordata: widget.seniordata,
                position: widget.data['position'],
              ),
            ),
          );
          return false; // Prevent the default back navigation
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 206, 238, 208),
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmpList(
                      seniordata: widget.seniordata,
                      position: widget.data['position'],
                    ),
                  ),
                );
              },
            ),
            title: Text('${widget.data['name']}'),
            actions: <Widget>[
              IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>  QuestionPage(seniordata: seniordata, data: data,pre: [],),
                                ),
                              );
                    },
                  ),
              ]),          
        body: FutureBuilder<List<String>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions found.'));
          } else {
            List<String> questions = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                bool isTablet = constraints.maxWidth > 600;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      buildEmployeeInfoCard(isTablet),
                      SizedBox(height: 16),
                      buildDateTimeRow(),
                      SizedBox(height: 6),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white, // Set the background color to white
                        ),
                        child: Opacity(
                          opacity: !_isPresent ? 1.0 : 0.5, // Set opacity based on the _show value
                          child:IgnorePointer(
                            ignoring: _isPresent, // Disable interaction if _show is false
                            child: Column(
                          children: List.generate(questions.length * 2 - 1, (index) {
                            if (index.isOdd) {
                              // Insert Divider between each child
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Divider(color: Colors.grey.withOpacity(0.5)),
                              );
                            } else {
                              // Build the actual child
                              int questionIndex = index ~/ 2;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Container(
                                  color: Colors.white, // Set the background color to white
                                  child: buildCheckboxRow(questionIndex, questions[questionIndex], isTablet),
                                ),
                              );
                            }
                          }),
                        ),
                        ))
                      ),
                      SizedBox(height: 6),
                      ErrorMessageWidget(showError: _showError,errormsg: 'Fill All the check box',),
                      buildTotalScoreRow(),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text('SUBMIT', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      ),
                      SizedBox(height: 20),
                      ConnectivityWidget(),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    ));
  }

  Widget buildEmployeeInfoCard(bool isTablet) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 187, 254, 191),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                            spreadRadius: 5, // How much the shadow spreads
                            blurRadius: 7, // How much the shadow blurs
                            offset: Offset(0, 3), // Offset of the shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width:110,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green, width: 1.5), // Set border color and width
                                  borderRadius: BorderRadius.circular(100.0), // Set border radius to match ClipRRect
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0), // Same border radius as BoxDecoration
                                  child: data['image'] != null && data['image'].isNotEmpty
                                      ? Image.network(
                                          data['image'],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.asset(
                                          'assets/images/DEFAULT.png', // Replace with your asset path
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              )
                            ),
                            Expanded(
                              child: Padding(
                                      padding: const EdgeInsets.all(10.0), // Add padding here
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // '${data['name'].toString().toUpperCase()}',
                                            '${data['name'][0].toString()+data['name'].toString().substring(1).toLowerCase()}',
                                             style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Nicholas',
                                              fontWeight: FontWeight.bold,
                                              ), // Adjust the font size as needed
                                          ),
                                          SizedBox(height: 1.0),
                                          Text(
                                            'Id - ${data['id']}',
                                             style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              ), // Adjust the font size as needed
                                          ),
                                          SizedBox(height: 7.0),
                                          Text(
                                            'Role',
                                             style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              ), // Adjust the font size as needed
                                          ),
                                          SizedBox(height: 2.0),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0), // Add padding here
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(255, 187, 254, 191), // Set background color here
                                              border: Border.all(color: Colors.green), // Set border color here
                                              borderRadius: BorderRadius.circular(50.0), // Set border radius here
                                            ),
                                            child: Text(
                                              '${data['position']}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
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
                  ConnectivityWidget(),
                ],
              ),
            
      );
  }

  Widget buildDateTimeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.green, // Set the background color to green
                  borderRadius: BorderRadius.circular(10.0), // Set border radius to 10
                ), 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    Text(
                      DateFormat('dd/MMM/yy  hh:mm a').format(time),
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w400,
                        color: Colors.white, // Set text color to white for better contrast
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Present',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // Set text color to white for better contrast
                            fontSize: 12.0,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8, // Adjust this scale factor to set the size
                          child: Switch(
                            value: _isPresent,
                            onChanged: (value) {
                              setState(() {
                                _isPresent = value;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 255, 255, 255), // Color when the switch is ON
                            inactiveThumbColor: const Color.fromARGB(255, 255, 255, 255), // Color of the thumb when the switch is OFF
                            inactiveTrackColor: Color.fromARGB(255, 194, 194, 194).withOpacity(0.5),
                            activeTrackColor: Color.fromARGB(255, 255, 0, 0),
                          ),
                        ),
                        Text(
                          'Absent',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                            color: Colors.white, // Set text color to white for better contrast
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                ],)
              ),
              
        
      ],
    );
  }

  Widget buildCheckboxRow(int index, String text, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 14,
              ),
          ),
        ),
        SizedBox(width: isTablet ? 40 : 10),
        Transform.scale(
          scale: 0.90, // Scale the checkbox down by 25%
          child: Checkbox(
            value: _yesValues[index],
            onChanged: (bool? newValue) {
              onCheckboxChanged(index, newValue, true);
            },
            activeColor: Colors.green, // Set the active color to green
          ),
        ),
        Text(
          'Yes',
          style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w400,
              fontSize: 14,
              ),
          ),
        SizedBox(width: isTablet ? 60 : 10),
        Transform.scale(
          scale: 0.90, // Scale the checkbox down by 25%
          child: Checkbox(
            value: _noValues[index],
            onChanged: (bool? newValue) {
              onCheckboxChanged(index, newValue, false);
            },
            activeColor: Colors.red, // Set the active color to green
          ),
        ),

        Text(
          'No',
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget buildTotalScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(width: 8),
        Text(
          'Total :  $value',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(width: 18, height: 40),
      ],
    );
  }
}
