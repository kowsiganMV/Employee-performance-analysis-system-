import 'package:app/screen/LoginPage.dart';
import 'package:flutter/material.dart';
import 'LocalDataManger.dart';
import 'EmployeList.dart';
import '../Appservices/connectivity_widget.dart';
import '../Appservices/Week_Mail.dart';
import '../DataBase/Mongodb.dart';
import 'PastEmp.dart';

class Homescreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final int val;
  const Homescreen({Key? key, required this.data, this.val = 0}) : super(key: key);
  

  @override
  _Homescreen createState() => _Homescreen(data: data, val: val);
}

class _Homescreen extends State<Homescreen> {
  final Map<String, dynamic> data;
  List<String> positions = [];
  List<String> adminPositions = [];
  LocalDataManager db = LocalDataManager();
  WeekMail week = WeekMail();
  int val = 0;
  List<String> Analyze=<String>[];
  List<String> delete=<String>[];
  Map<String, dynamic> Pos_Image={};
  bool isLoading = false;
  _Homescreen({required this.data, required this.val});

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
    delete=await MongoDatabase.get_Com("delete");
    Pos_Image=await MongoDatabase.get_img("Position images");
    List<String> pos = await db.get_position(data['position']);
    if (Analyze.contains(data['position'])) {
      List<String> adminPos = await db.get_position("HR");
      setState(() {
        positions = pos;
        adminPositions = adminPos;
      });
    } else {
      setState(() {
        positions = pos;
      });
    }
    setState(() {
      isLoading = false; // Start loading
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 255, 255), // Set the background color to light green
        actions: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginPage(), // Navigate to LoginPage
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.green, // Button background color
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
                      Navigator.of(context).pop(false); // Close the dialog without navigating
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 248, 0, 0),
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
          child: const Text(
            'Do you want to Logout?',
            style: TextStyle(fontSize: 20),
          ),
        ),
        contentPadding: const EdgeInsets.all(20.0),
      ),
    ) ??
    false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 2,
        initialIndex: val,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false, // Ensures the back button is not displayed
            bottom: TabBar(
              tabs: [
                Tab(text: 'Profile'),
                Tab(text: 'Performance Appraisal'),
              ],
            ),
            title: Text("Jayashree Spun Bond"),
            backgroundColor: Colors.green,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _initialData();
                },
              ),
               if (isLoading)
                Center(
                  child: CircularProgressIndicator(), // Show loading indicator in the center
                ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Color.fromARGB(255, 255, 255, 255), // Set the background color to light green
                      actions: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 100,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(), // Navigate to LoginPage
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.green, // Button background color
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
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 248, 0, 0),
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
                        child: const Text(
                          'Do you want to Logout?',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20.0),
                    ),
                  );
                },
              ),
            ],
          ),
          backgroundColor: Color.fromARGB(255, 199, 243, 201),
          body: TabBarView(
            children: [
              _buildProfileTab(),
              _buildPerformanceAppraisalTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildProfileHeader(),
          ConnectivityWidget(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(children: [ 
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
                _buildProfileImage(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['name'][0].toString().toUpperCase()}${data['name'].toString().substring(1).toLowerCase()}',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Nicholas',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.0),
                        Text(
                          'Id - ${data['id']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 7.0),
                        Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.0),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 187, 254, 191),
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Text(
                            '${data['position']}',
                            style: TextStyle(
                              fontSize: 12,
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
      delete.contains(data['position'])?InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Pastemp(seniordata: data,),
            ),
          );
        },
        child: Padding(
            padding: EdgeInsets.all(15),
            child:Container(
            width: double.infinity,  // Set width to 300
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 109, 173, 118),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26, // Shadow color
                  offset: Offset(0, 4), // Shadow position (x, y)
                  blurRadius: 8.0, // Shadow blur
                ),
              ],
            ),
            child:Center(child: Text('Past Employee History',
                style: TextStyle(
                fontSize: 15,
                fontFamily: 'Nicholas',
                fontWeight: FontWeight.bold,
            ),),) ,
          ),
        ),
      ):Container()


    ],);
  }

  Widget _buildProfileImage() {
    return Container(
      alignment: Alignment.center,
      width: 110,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 1.5),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: data['image'] != null && data['image'].isNotEmpty
              ? Image.network(
                  data['image'],
                  width: 90,
                  height: 90,
                  fit: BoxFit.fill,
                )
              : Image.asset(
                  'assets/images/DEFAULT.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }

  Widget _buildPerformanceAppraisalTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPositionWidgets(positions),
          if (Analyze.contains(data['position']) )
            _buildAdminPositionWidgets(adminPositions),
        ],
      ),
    );
  }

  Widget _buildPositionWidgets(List<String> positions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalPadding = constraints.maxWidth > 600 ? 60.0 : 20.0;
        double horizontalSpacing = constraints.maxWidth > 600 ? 150.0 : 20.0;

        return SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: horizontalPadding),
                  child: Wrap(
                    spacing: horizontalSpacing,
                    runSpacing: 40.0,
                    alignment: WrapAlignment.center,
                    children: positions.map((position) => _buildPositionWidget(position)).toList(),
                  ),
                ),
              ),
              _adminworks(),
            ],
          ),
        );
      },
    );
  }

  Widget _adminworks() {
    if (Analyze.contains(data['position']))
      return Container(
        height: 40, // Set the desired height
        width: double.infinity, // This makes the Container take up the full width
        color: Color.fromARGB(186, 54, 135, 0), // Set your desired background color here
        child: Center( // Center the text within the Container
          child: Text(
            "ADMIN WORKS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    else
      return Container();
  }

  Widget _buildAdminPositionWidgets(List<String> adminPositions) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalPadding = constraints.maxWidth > 600 ? 60.0 : 20.0;
        double horizontalSpacing = constraints.maxWidth > 600 ? 150.0 : 20.0;

        return SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: horizontalPadding),
                  child: Wrap(
                    spacing: horizontalSpacing,
                    runSpacing: 40.0,
                    alignment: WrapAlignment.center,
                    children: adminPositions.map((position) => _buildAdminPositionWidget(position)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPositionWidget(String position) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmpList(
              seniordata: data,
              position: position,
            ),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10.0),
            width: 150,
            height: 190,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Image.network(
                  Pos_Image[position],
                  width: 90,
                  height: 90,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 15),
                Text(
                  position,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPositionWidget(String position) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmpList(
              seniordata: data,
              position: position,
            ),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.all(10.0),
            width: 150,
            height: 190,
            decoration: BoxDecoration(
              color: Color.fromARGB(186, 54, 135, 0), // Different color for admin positions
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Image.network(
                  Pos_Image[position],
                  width: 90,
                  height: 90,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 15),
                Text(
                  position,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
