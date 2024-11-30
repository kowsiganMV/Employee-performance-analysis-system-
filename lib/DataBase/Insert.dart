import 'package:app/DataBase/MongoDBModel.dart';
import 'package:flutter/material.dart';
import 'Mongodb.dart';

class MongoDbInsert extends StatefulWidget {
  MongoDbInsert({Key? key}) : super(key: key);

  @override
  _MongoState createState() => _MongoState();
}

class _MongoState extends State<MongoDbInsert> {
  var IdConstroller=new TextEditingController();
  var NameController=new TextEditingController();
  var PositionController=new TextEditingController();
  var HeadController=new TextEditingController();
  var ImageController=new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding( 
          padding: const EdgeInsets.all(15.0),
          child:Column(
          children: [
            Text(
              "Insert Data",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 50,),
            TextField(
              controller: IdConstroller,
              decoration: InputDecoration(labelText: "ID"),
            ),
            TextField(
              controller: NameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: PositionController,
              decoration: InputDecoration(labelText: "Position"),
            ),
            TextField(
              controller: HeadController,
              decoration: InputDecoration(labelText: "Head"),
            ),
            TextField(
              controller: ImageController,
              decoration: InputDecoration(labelText: "Image"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  _insertData(IdConstroller.text,NameController.text,PositionController.text,HeadController.text,ImageController.text);
                }, child: Text("Insert"))
              ],
            ),
            SizedBox(height: 50,),
          ],
        ),
      )
      ),
    );
  }
  Future<void> _insertData(String id,String name, String position ,String head,String image) async {
    final data=MongoDbModel(id: id, name: name, position: position, head: head,image: image);
    var res=await MongoDatabase.Insert(data);
    print(res);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("inserted Id")));
    clearall();
  }

  void clearall(){
    IdConstroller.text="";
    NameController.text="";
    PositionController.text="";
    HeadController.text="";
    ImageController.text="";
  }
}

