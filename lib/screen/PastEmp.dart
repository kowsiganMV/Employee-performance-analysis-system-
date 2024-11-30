import 'package:app/screen/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app/screen/LocalDataManger.dart';
import '../Appservices/connectivity_widget.dart';
import 'PastreReport.dart';
import '../DataBase/Mongodb.dart';

class Pastemp extends StatefulWidget {
  final Map<String, dynamic> seniordata;

  const Pastemp({
    super.key, 
    required this.seniordata, 
  });

  @override
  Employe createState() => Employe(
    seniordata: seniordata, 
  );
}

class Employe extends State<Pastemp> {
  final Map<String, dynamic> seniordata;
  LocalDataManager db = LocalDataManager();
  List<Map<String, dynamic>> data=List.empty();
  bool isLoading = false;

  Employe({
    required this.seniordata, 
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
    List<Map<String, dynamic>> temp = await MongoDatabase.get_past_Emp();
    setState(() {
      data=temp;
    });
    await getpoints();
    setState(() {
      isLoading = false; // stop loading
    });
  }
  Future<void> getpoints() async {
    for(int i=0;i<data.length;i++){
      List<double> val=await MongoDatabase.get_mark(data[i]['id']);
      setState(() {
        data[i]['points']=val[1];
        data[i]['totpoints']=val[0].toInt();
      });
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homescreen(data: seniordata,val: 0,),
      ),
    );
    return false; // Return false to prevent the default back navigation
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            width: double.infinity,
                            height: 250,
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
                                          Column(children: [
                                              Text(
                                              'Leave Date :',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                              ), // Adjust the font size as needed
                                            ),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0), // Add padding here
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 250, 43, 43), // Set background color here
                                                border: Border.all(color: Colors.green), // Set border color here
                                                borderRadius: BorderRadius.circular(50.0), // Set border radius here
                                              ),
                                              child: Text(
                                                '${employee['leave_date']}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: const Color.fromARGB(255, 255, 255, 255),
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            ],),
                                            Text(
                                              'Points :',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
                                              ), // Adjust the font size as needed
                                            ),
                                            Container(
                                              padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0), // Add padding here
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(255, 92, 155, 83), // Set background color here
                                                border: Border.all(color: Colors.green), // Set border color here
                                                borderRadius: BorderRadius.circular(50.0), // Set border radius here
                                              ),
                                              child: Text(
                                                '${employee['points']} / ${employee['totpoints']}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: const Color.fromARGB(255, 255, 255, 255),
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
                builder: (context) => Homescreen(data: seniordata,val:0),
              ),
            );
          },
        ),
        title: Text(
          "Past Employees",
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
              ),]
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 2),
                Divider(color: Colors.grey.withOpacity(0.5)),
                SizedBox(height: 10),
                ...data.map((Map<String, dynamic> employee) => buildEmployeeCard(context, employee,true)).toList(),
                Divider(color: Colors.grey.withOpacity(0.5)),
                ConnectivityWidget(),
              ],
            ),
          );
        },
      ),
    );
  }
}
