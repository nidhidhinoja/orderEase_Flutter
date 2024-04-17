import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/services/firestore.dart';
import 'package:flutterapp/pages/menubarDrawer.dart';
import 'package:flutterapp/pages/homePage.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController orderNameController = TextEditingController();
  final TextEditingController orderDescriptionController =
  TextEditingController();

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
            "Orders",
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
          onPressed: () => openOrderBox(),
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue.withOpacity(0.7),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getOrdersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List orderList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = orderList[index];
                  String orderId = document.id;
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  String orderName = data['name'];
                  String orderDescription = data['description'];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        orderName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(orderDescription),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => openOrderBox(
                              orderId: orderId,
                              initialName: orderName,
                              initialDescription: orderDescription,
                            ),
                            icon: const Icon(Icons.settings),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete', style: TextStyle(color: Colors.black)),
                                    content: Text('Are you sure you want to delete this order?', style: TextStyle(color: Colors.black)),
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
                                          fireStoreService.deleteOrder(orderId);
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

  void openOrderBox({
    String? orderId,
    String? initialName,
    String? initialDescription,
  }) async {
    String? selectedClientId;
    List<String> clientIds = [];
    List<String> clientNames = [];

    await FirebaseFirestore.instance.collection('clients').get().then((value) {
      value.docs.forEach((element) {
        clientIds.add(element.id);
        clientNames.add(element['name']);
      });
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                    value: selectedClientId,
                    items: clientIds
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(clientNames[clientIds.indexOf(e)]),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClientId = value as String?;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Select Client'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: orderNameController..text = initialName ?? '',
                    decoration: InputDecoration(
                      labelText: 'Order Name',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: orderDescriptionController
                      ..text = initialDescription ?? '',
                    decoration: InputDecoration(
                      labelText: 'Order Description',
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Save button action
                    if (orderId == null) {
                      if (selectedClientId == null) {
                        // Handle case where no client is selected
                        return;
                      }
                      fireStoreService.addOrder(
                        orderNameController.text,
                        orderDescriptionController.text,
                        selectedClientId!,
                      );
                    } else {
                      fireStoreService.updateOrder(
                        orderId,
                        orderNameController.text,
                        orderDescriptionController.text,
                      );
                    }
                    orderNameController.clear();
                    orderDescriptionController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue.withOpacity(0.7),
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}
