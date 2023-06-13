import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/auth/auth_service.dart';
import 'package:todo_app/main.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> documents = [];
  List<bool> checkedItems = [];
  bool isChecked = false;
  TextEditingController _todocontrollere = TextEditingController();
  AuthClass authClass = AuthClass();
  @override
  void initState() {
    super.initState();
    fetchData();
    setState(() {});
  }

  Future<void> fetchData() async {
    try {
      final CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('Collection');
      final QuerySnapshot snapshot =
          await collectionRef.orderBy("time", descending: true).get();
      final List<QueryDocumentSnapshot> fetchedDocuments = snapshot.docs;

      setState(() {
        documents = fetchedDocuments
            .map((document) => document.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (error) {
      print('Error retrieving documents: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await authClass.signOut(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => MyApp()),
                    (route) => false);
              }),
        ],
      ),
      body: ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final documentData = documents[index];
            final String title = documentData['data'] as String;

            return Card(
              child: ListTile(
                tileColor: documents[index]["finish"] == true
                    ? Colors.grey
                    : Colors.grey.shade300,
                title: Text(
                  title,
                  style: documents[index]["finish"] == true
                      ? TextStyle(decoration: TextDecoration.lineThrough)
                      : TextStyle(),
                ),
                leading: IconButton(
                    onPressed: () {
                      bool update = isChecked = !isChecked;
                      FirebaseFirestore.instance
                          .collection("Collection")
                          .doc(title)
                          .update({'finish': update});
                      setState(() {
                        fetchData();
                      });
                    },
                    icon: Icon(documents[index]["finish"] == true
                        ? Icons.check_box
                        : Icons.check_box_outline_blank)),
                // leading: Checkbox(
                //   value: checkedItems[index],
                //   onChanged: (bool? value) {
                //     setState(() {
                //       checkedItems[index] = value!;
                //     });
                //   },
                // ),
                trailing: IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("Collection")
                          .doc(title)
                          .delete();
                      setState(() {
                        fetchData();
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade300,
                    )),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.greenAccent,
          onPressed: () {
            _showDialog(context);
          },
          child: Icon(Icons.add)),
    );
  }

  _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 20,
          title: Text("Add new work"),
          content: TextFormField(
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.edit),
              hintText: "Add To List",
            ),
            controller: _todocontrollere,
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(
              width: 20,
            ),
            ElevatedButton(
              child: Text("Add"),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("Collection")
                    .doc(_todocontrollere.text)
                    .set({
                  "data": _todocontrollere.text,
                  "time": DateTime.now(),
                  "finish": false
                });
                setState(() {
                  fetchData();
                });
                Navigator.of(context).pop();
                _todocontrollere.clear();
              },
            ),
          ],
        );
      },
    );
  }
}
