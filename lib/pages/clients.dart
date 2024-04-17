import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/services/firestore.dart';
import 'package:flutterapp/pages/menubarDrawer.dart';
import 'package:flutterapp/pages/homePage.dart';
import 'package:flutterapp/pages/orders.dart'; // Import Orders page

class Clients extends StatefulWidget {
  const Clients({Key? key}) : super(key: key);

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
            ),
          ),
          title: Text(
            "Clients",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openClientBox(),
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue.withOpacity(0.7),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getClientsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List clientList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: clientList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = clientList[index];
                  String docID = document.id;
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  String clientName = data['name'];
                  String phoneNumber = data['phoneNumber'];
                  String city = data['city'];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        clientName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone: $phoneNumber"),
                          Text("City: $city"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => openOrderBoxForClient(docID: docID),
                            icon: const Icon(Icons.add_box),
                          ),
                          IconButton(
                            onPressed: () => openClientBox(docID: docID),
                            icon: const Icon(Icons.settings),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete', style: TextStyle(color: Colors.black)),
                                    content: Text('Are you sure you want to delete this client?', style: TextStyle(color: Colors.black)),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text('Cancel', style: TextStyle(color: Colors.blue)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final fireStoreService = FireStoreService();
                                          fireStoreService.deleteClient(docID);
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        child: Text('Delete', style: TextStyle(color: Colors.white)),
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.withOpacity(0.7)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        drawer: MenuBarDrawer(),
      ),
    );
  }

  void openClientBox({String? docID}) async {
    String? name;
    String? phoneNumber;
    String? city;

    if (docID != null) {
      DocumentSnapshot documentSnapshot =
      await fireStoreService.clientsCollection.doc(docID).get();
      Map<String, dynamic> data =
      documentSnapshot.data() as Map<String, dynamic>;
      name = data['name'];
      phoneNumber = data['phoneNumber'];
      city = data['city'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController..text = name ?? '',
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: phoneNumberController..text = phoneNumber ?? '',
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            TextField(
              controller: cityController..text = city ?? '',
              decoration: InputDecoration(
                labelText: 'City',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                fireStoreService.addClient(
                  nameController.text,
                  phoneNumberController.text,
                  cityController.text,
                );
              } else {
                fireStoreService.updateClient(
                  docID,
                  nameController.text,
                  phoneNumberController.text,
                  cityController.text,
                );
              }
              nameController.clear();
              phoneNumberController.clear();
              cityController.clear();
              Navigator.pop(context);
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blue.withOpacity(0.7),
              ),
            ),
          )
        ],
      ),
    );
  }

  void openOrderBoxForClient({required String docID}) async {
    String? orderName;
    String? orderDescription;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController()..text = orderName ?? '',
              onChanged: (value) => orderName = value,
              decoration: InputDecoration(
                labelText: 'Order Name',
              ),
            ),
            TextField(
              controller: TextEditingController()..text = orderDescription ?? '',
              onChanged: (value) => orderDescription = value,
              decoration: InputDecoration(
                labelText: 'Order Description',
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (orderName != null && orderDescription != null) {
                try {
                  await FireStoreService().addOrder(orderName!, orderDescription!, docID);
                } catch (e) {
                  print("Error adding order: $e");
                }
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Add Order",
              style: TextStyle(color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.blue.withOpacity(0.7),
              ),
            ),
          )
        ],
      ),
    );
  }
}
