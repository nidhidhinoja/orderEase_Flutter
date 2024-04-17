import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menubarDrawer.dart';
import 'homePage.dart'; // Import the HomePage widget

class DownloadInvoice extends StatefulWidget {
  @override
  _DownloadInvoiceState createState() => _DownloadInvoiceState();
}

class _DownloadInvoiceState extends State<DownloadInvoice> {
  String? selectedClient;
  List<String> selectedOrders = [];
  List<Map<String, dynamic>> orderDetails = [];
  TextEditingController descriptionController = TextEditingController();
  TextEditingController designChargeController = TextEditingController();
  TextEditingController rptChargeController = TextEditingController();
  TextEditingController otherChargesController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()), // Navigate back to HomePage
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
            ),
          ),
          title: Text(
            "Download Invoice Page",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        drawer: MenuBarDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: firestore.collection('clients').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    List<String> clients = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
                    return DropdownButtonFormField<String>(
                      value: selectedClient,
                      hint: Text('Select Client'),
                      items: clients.map((client) {
                        return DropdownMenuItem<String>(
                          value: client,
                          child: Text(client),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedClient = value;
                          selectedOrders.clear();
                          orderDetails.clear();
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                if (selectedClient != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection('orders').where('clientId', isEqualTo: selectedClient).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      List<String> orders = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Orders:'),
                          Wrap(
                            spacing: 8.0,
                            children: orders.map((order) {
                              return FilterChip(
                                label: Text(order),
                                selected: selectedOrders.contains(order),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedOrders.add(order);
                                    } else {
                                      selectedOrders.remove(order);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement logic to view/download invoice
                  },
                  child: Text('View/Download Invoice'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DownloadInvoice(),
  ));
}
