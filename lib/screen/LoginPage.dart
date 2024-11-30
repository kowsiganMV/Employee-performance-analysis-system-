import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'LocalDataManger.dart';
import 'package:app/screen/HomeScreen.dart';
import 'package:app/screen/ErrorWidget.dart';
import '../Appservices/connectivity_widget.dart';
import '../DataBase/Mongodb.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showError = false;
  TextEditingController name = TextEditingController();
  TextEditingController id = TextEditingController();
  LocalDataManager db = LocalDataManager();
  bool isLoading = false;

  void _login() async {
    String _name = name.text.trim();
    String _id = id.text.trim();
    await db.loadlogins();
    if (_name.length <= 20 && _id.length <= 20) {
      if (db.loginCheck(_name, _id)) {
        print("Successfully Logged in: " + _name.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Homescreen(data: db.set_user(_id), val: 0),
          ),
        );
      } else {
        setState(() {
          _showError = true;
        });
      }
    } else {
      setState(() {
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitConfirmationDialog();
        if (shouldExit) {
          SystemNavigator.pop(); // Closes the app
        }
        return false; // Prevents the default back navigation
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double containerPadding = constraints.maxWidth > 600 ? 40.0 : 20.0;
            double logoSize = constraints.maxWidth > 600 ? 60.0 : 40.0;
            double inputFontSize = constraints.maxWidth > 600 ? 18.0 : 14.0;
            double buttonFontSize = constraints.maxWidth > 600 ? 18.0 : 14.0;

            return SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    colors: [
                      Color.fromARGB(255, 139, 247, 143),
                      Color.fromARGB(255, 149, 236, 152),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.all(containerPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _fadeInUp(
                            duration: Duration(milliseconds: 1000),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 18, 16, 16),
                                fontSize: logoSize,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          _fadeInUp(
                            duration: Duration(milliseconds: 1300),
                            child: Text(
                              "Welcome Back",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 18, 16, 16),
                                fontSize: inputFontSize,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () async {
                              setState(() {
                                isLoading=true;
                              });
                              await MongoDatabase.connect();
                              setState(() {
                                isLoading=false;
                              });
                            }
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(containerPadding),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 60),
                            _fadeInUp(
                              duration: Duration(milliseconds: 1400),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(225, 95, 27, .3),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: name,
                                        decoration: InputDecoration(
                                          hintText: "Username",
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: inputFontSize,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: id,
                                        decoration: InputDecoration(
                                          hintText: "Password",
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: inputFontSize,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        obscureText: true,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                      ),
                                    ),
                                    ErrorMessageWidget(
                                      showError: _showError,
                                      errormsg:
                                          'Error: Please enter valid credentials.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            if (isLoading)
                              Center(
                                child: CircularProgressIndicator(), // Show loading indicator in the center
                              )
                            else
                            _fadeInUp(
                              duration: Duration(milliseconds: 1600),
                              child: OutlinedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: buttonFontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                    ConnectivityWidget(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit App"),
        content: Text("Are you sure you want to exit the app?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _fadeInUp({required Duration duration, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: Offset(0, 30), end: Offset(0, 0)),
      duration: duration,
      builder: (context, Offset offset, child) {
        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: child,
    );
  }
}
