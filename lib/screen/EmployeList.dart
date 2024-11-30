import 'dart:ffi';

import 'package:app/screen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'second.dart';
import 'package:app/screen/LocalDataManger.dart';
import '../Appservices/connectivity_widget.dart';
import 'Analysis.dart';
import '../DataBase/Mongodb.dart';

class EmpList extends StatefulWidget {
  final Map<String, dynamic> seniordata;
  final dynamic position;

  const EmpList({
    super.key, 
    required this.seniordata, 
    required this.position
  });

  @override
  Employe createState() => Employe(
    seniordata: seniordata, 
    position: position,
  );
}

class Employe extends State<EmpList> {
  final Map<String, dynamic> seniordata;
  final dynamic position;
  LocalDataManager db = LocalDataManager();
  List<Map<String, dynamic>> data=List.empty();
  List<Map<String, dynamic>> Filled=List.empty();
  List<Map<String, dynamic>> pre =List.empty();
  List<String> Analyze=<String>[];
  List<String> Edit=<String>[];
  List<String> delete=<String>[];
  bool _isDelete=false;
  bool isLoading = false;

  Employe({
    required this.seniordata, 
    required this.position,
  });

  @override
  void initState() {
    super.initState();
    _initialData();
  }

  Future<void> _initialData() async {
    setState(() {
      isLoading = true; // Start loading
    });
    Analyze=await MongoDatabase.get_Com("Analyze");
    Edit=await MongoDatabase.get_Com("Edit");
    delete=await MongoDatabase.get_Com("delete");
    List<List<Map<String, dynamic>>> temp=await db.get_Emp_Detail(position);
    List<Map<String, dynamic>> temp1 = await db.today_entry(position, DateTime.now());
    setState(() {
      data=temp[1];
      Filled=temp[0];
      pre=temp1;
      isLoading = false;
    });
  }

 Future<void> HandleDelete(Map<String, dynamic> employee) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      actions: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 100,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await MongoDatabase.deleteEmployee(employee);
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => EmpList(
                            seniordata: seniordata,
                            position: position,
                          ),
                        ),
                      );
                    } catch (e) {
                      // Handle the error if the delete operation fails
                      print("Error deleting employee: $e");
                      Navigator.of(context).pop(); // Close the dialog
                      // Optionally show a snackbar or dialog with the error message
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 248, 0, 0),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      title: Center(
        child: Text(
          "Do you want to delete ${employee['name']}?",
          style: const TextStyle(fontSize: 20),
        ),
      ),
      contentPadding: const EdgeInsets.all(20.0),
    ),
  );
}


  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homescreen(data: seniordata,val: 1,),
      ),
    );
    return false; // Return false to prevent the default back navigation
  }

  List<int> previous(String id){
    for(Map<String, dynamic> i in pre){
      if(i['id'].toString()==id)
      return i['answers'].toList();
    }
    return List.empty();
  }

  
  Widget buildEmployeeCard(BuildContext context, Map<String, dynamic> employee, bool _show) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: [
          Opacity(
            opacity: _show ? 1.0 : 0.5, // Set opacity based on the _show value
            child: IgnorePointer(
              ignoring: !_show, // Disable interaction if _show is false
              child: Column(
                children: [
                  InkWell(
                    onTap: _show
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionPage(seniordata: seniordata, data: employee,pre: [],),
                            ),
                          );
                        }
                      : null, // Disable tap if _show is false
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            width: double.infinity,
                            height: 160,
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
                                    width: 110,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green, width: 1.5), // Set border color and width
                                        borderRadius: BorderRadius.circular(100.0), // Set border radius to match ClipRRect
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100.0), // Same border radius as BoxDecoration
                                        child: employee['image'] != null && employee['image'].isNotEmpty
                                          ? Image.network(
                                              employee['image'],
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
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0), // Add padding here
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${employee['name'][0].toString() + employee['name'].toString().substring(1).toLowerCase()}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Nicholas',
                                              fontWeight: FontWeight.bold,
                                            ), // Adjust the font size as needed
                                          ),
                                          Text(
                                            'Id - ${employee['id']}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                            ), // Adjust the font size as needed
                                          ),
                                          SizedBox(height: 5.0),
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
                                              '${employee['position']}',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // 16 pixels of padding on all sides
            child:Row(
                      children: [
                        Visibility(
                          visible: Analyze.contains(seniordata['position']), // Simplified condition
                          child: Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnalysisScreen(
                                      seniordata: seniordata,
                                      data: employee,
                                      lastDate: DateTime.now(),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Analyze',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.green), // Border color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: Edit.contains(seniordata['position']) && !_show, // Simplified condition
                          child: Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuestionPage(seniordata: seniordata, data: employee, pre: previous(employee['id'].toString())),
                                  ),
                                );
                              },
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.green), // Border color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: delete.contains(seniordata['position']) && _isDelete , // Simplified condition
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: (){
                              HandleDelete(employee);
                            },
                          ),
                        ),
                      ],
                    )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 206, 238, 208),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Homescreen(data: seniordata,val:1),
              ),
            );
          },
        ),
        title: Text(
          position.toString()+"S",
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 12),
        ),
        actions: <Widget>[
          IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () async {
                  await _initialData();
                },
              ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(), // Show loading indicator in the center
              ),
          Visibility(
                          visible: delete.contains(seniordata['position']) , // Simplified condition
                          child: Transform.scale(
                          scale: 0.8, // Adjust this scale factor to set the size
                          child: Switch(
                            value: _isDelete,
                            onChanged: (value) {
                              setState(() {
                                _isDelete = value;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 255, 255, 255), // Color when the switch is ON
                            inactiveThumbColor: const Color.fromARGB(255, 255, 255, 255), // Color of the thumb when the switch is OFF
                            inactiveTrackColor: Color.fromARGB(255, 194, 194, 194).withOpacity(0.5),
                            activeTrackColor: Color.fromARGB(255, 255, 0, 0),
                          ),
                        ),
          ),
        ]
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Filled : ${Filled.length}",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Nicholas',
                        fontWeight: FontWeight.bold,
                      ), // Adjust the font size as needed
                    ),
                    Text(
                      "Not Filled : ${data.length}",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Nicholas',
                        fontWeight: FontWeight.bold,
                      ), // Adjust the font size as needed
                    ),
                    
                  ],
                ),
                Divider(color: Colors.grey.withOpacity(0.5)),
                SizedBox(height: 10),
                ...data.map((Map<String, dynamic> employee) => buildEmployeeCard(context, employee,true)).toList(),
                Divider(color: Colors.grey.withOpacity(0.5)),
                Text(
                  "Filled",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Nicholas',
                    fontWeight: FontWeight.bold,
                  ), // Adjust the font size as needed
                ),
                ...Filled.map((Map<String, dynamic> employee) => buildEmployeeCard(context, employee,false)).toList(),
                ConnectivityWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
