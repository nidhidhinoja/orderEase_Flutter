import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/services/firestore.dart';
import 'package:flutterapp/pages/menubarDrawer.dart';
import 'package:flutterapp/pages/homePage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Import for PDF widgets
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class Invoices extends StatefulWidget {
  const Invoices({Key? key}) : super(key: key);

  @override
  State<Invoices> createState() => _InvoicesState();
}

class _InvoicesState extends State<Invoices> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController invoiceNameController = TextEditingController();
  final TextEditingController invoiceDescriptionController = TextEditingController();
  File? selectedImage;
  Uint8List? _image;

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
            "Invoices",
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
          onPressed: () => openInvoiceBox(),
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue.withOpacity(0.7),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: fireStoreService.getInvoicesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List invoiceList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: invoiceList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = invoiceList[index];
                  String invoiceId = document.id;
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  String invoiceName = data['name'];
                  String invoiceDescription = data['description'];
                  String clientId = data['clientId']; // Fetching clientId
                  List<
                      dynamic> orderIds = data['orderIds']; // Fetching orderIds

                  // Fetch client name
                  Future<String> clientNameFuture = fireStoreService
                      .getClientName(clientId)
                      .then((value) => value['name'] ?? '');

                  // Fetch order details
                  Future<List<String>> orderNamesFuture = Future.wait(
                      orderIds.map(
                              (orderId) async =>
                          (await fireStoreService.getOrder(orderId))
                          ['name'] ??
                              ''));

                  return FutureBuilder(
                    future: Future.wait([clientNameFuture, orderNamesFuture]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String clientName = (snapshot.data![0] as String?) ??
                            '';
                        List<String> orderNames =
                            (snapshot.data![1] as List<dynamic>?)?.map<String>((
                                e) => e.toString()).toList() ?? [];

                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              invoiceName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Client: $clientName"),
                                Text("Orders: ${orderNames.join(', ')}"),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    // Get invoice details for the clicked invoice
                                    DocumentSnapshot document = invoiceList[index];
                                    String invoiceId = document.id;
                                    Map<String, dynamic> data = document
                                        .data()! as Map<String, dynamic>;
                                    String invoiceName = data['name'];
                                    String invoiceDescription = data['description'];
                                    String clientId = data['clientId'];
                                    List<String> orderIds = List<String>.from(
                                        data['orderIds']); // Convert to List<String>

                                    // Fetch client name and order details as before
                                    Map<String,
                                        dynamic> clientData = await fireStoreService
                                        .getClientName(clientId);
                                    String clientName = clientData['name'] as String;

                                    List<Map<String, dynamic>> orderDetails = [
                                    ];
                                    for (var orderId in orderIds) {
                                      Map<String,
                                          dynamic> orderData = await fireStoreService
                                          .getOrder(orderId);
                                      orderDetails.add(orderData);
                                    }

                                    // Generate the PDF
                                    final pdfData = await generateInvoicePdf(
                                      'Keval Dhinoja Design',
                                      'assets/images/kd3.png',
                                      '+91 88494 30929',
                                      'Rajkot, Gujarat.',
                                      clientName,
                                      orderDetails,
                                    );

                                    // Show a download dialog or use a file picker to save the PDF
                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Save Invoice'),
                                          content: Text(
                                              'Do you want to save the invoice as a PDF?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            // Inside your save button onPressed callback
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Generate the PDF
                                                final Uint8List pdfData = await generateInvoicePdf(
                                                  'Keval Dhinoja Design',
                                                  'assets/images/kd3.png',
                                                  '+91 88494 30929',
                                                  'Rajkot, Gujarat.',
                                                  clientName,
                                                  orderDetails,
                                                );

                                                // Get the downloads directory
                                                final String downloadsDirectory = (await getDownloadsDirectory())!
                                                    .path;

                                                final String uniqueId = Uuid().v4(); // Generate a UUID
                                                final String filePath = '/storage/emulated/0/Download/Cust${clientName}Invoice_$uniqueId.pdf';

                                                // Write the PDF data to the file
                                                final File file = File(
                                                    filePath);
                                                await file.writeAsBytes(
                                                    pdfData);

                                                // Show a message indicating that the invoice has been saved
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(content: Text(
                                                      'Invoice saved to $filePath')),
                                                );

                                                Navigator.pop(
                                                    context); // Close the dialog
                                              },
                                              child: Text('Save'),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.print),
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          content: Text(
                                              'Are you sure you want to delete this invoice?',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: Text('Cancel',
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final fireStoreService = FireStoreService();
                                                fireStoreService.deleteInvoice(
                                                    invoiceId);
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty
                                                    .all<Color>(
                                                    Colors.blue.withOpacity(
                                                        0.7)),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                      Icons.delete, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
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

  void openInvoiceBox() async {
    String? selectedClientId;
    List<String> selectedOrderIds = [];

    List<String> clientIds = [];
    List<String> clientNames = [];
    Map<String, List<String>> orderMap = {};

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
                        .map((e) =>
                        DropdownMenuItem(
                          value: e,
                          child: Text(clientNames[clientIds.indexOf(e)]),
                        ))
                        .toList(),
                    onChanged: (value) async {
                      setState(() {
                        selectedClientId = value as String?;
                        selectedOrderIds.clear();
                      });
                      if (selectedClientId != null) {
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .where('clientId', isEqualTo: selectedClientId)
                            .get()
                            .then((value) {
                          value.docs.forEach((element) {
                            orderMap[element.id] = [
                              element['name'],
                              element['description']
                            ];
                          });
                        });
                        setState(() {});
                      }
                    },
                    decoration: InputDecoration(labelText: 'Select Client'),
                  ),
                  SizedBox(height: 10),
                  if (selectedClientId != null) ...[
                    SizedBox(
                      height: 200,
                      child: ListView(
                        children: orderMap.keys.map((orderId) {
                          return CheckboxListTile(
                            title: Text(orderMap[orderId]![0]),
                            subtitle: Text(orderMap[orderId]![1]),
                            value: selectedOrderIds.contains(orderId),
                            onChanged: (value) {
                              setState(() {
                                if (value != null && value) {
                                  selectedOrderIds.add(orderId);
                                } else {
                                  selectedOrderIds.remove(orderId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Next button action
                    Navigator.pop(context);
                    // Call the function with selected details
                    openInvoiceDetails(
                      selectedClientId,
                      selectedOrderIds,
                      clientNames,
                      orderMap,
                    );
                  },
                  child: const Text(
                    "Next",
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

  void openInvoiceDetails(String? clientId, List<String> orderIds, List<String> clientNames, Map<String, List<String>> orderMap) async {
    for (String orderId in orderIds) {
      String? imageFilePath;
      TextEditingController designChargeController = TextEditingController();
      TextEditingController rptChargeController = TextEditingController();
      TextEditingController otherChargeController = TextEditingController();
      TextEditingController orderDescriptionController =
      TextEditingController(); // New controller for order description

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order: $orderId"),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await showImagePickerOption(context);
                    },
                    child: Text('Add Image'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: orderDescriptionController,
                    // Use the new controller for order description
                    decoration: InputDecoration(labelText: 'Order Description'),
                    // Label for order description
                    keyboardType: TextInputType
                        .text, // Use text input type for description
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: designChargeController,
                    decoration: InputDecoration(labelText: 'Design Charge'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: rptChargeController,
                    decoration: InputDecoration(labelText: 'RPT Charge'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: otherChargeController,
                    decoration: InputDecoration(labelText: 'Other Charge'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Save invoice details for current order
                  String name = clientId!;
                  String description = orderDescriptionController.text;
                  String designCharge = designChargeController.text;
                  String rptCharge = rptChargeController.text;
                  String otherCharge = otherChargeController.text;

                  // Save invoice details
                  fireStoreService.addInvoice(
                    name,
                    description,
                    clientId!, // Ensure clientId is non-nullable
                    [orderId], // Pass orderId as a single-element list
                    imageFilePath,
                    designCharge,
                    rptCharge,
                    otherCharge,
                  );
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> showImagePickerOption(BuildContext context) async {
    showModalBottomSheet(
      backgroundColor: Theme
          .of(context)
          .backgroundColor,
      context: context,
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.withOpacity(0.7),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  _pickImageFromCamera();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.withOpacity(0.7),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Camera",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final returnImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop(); //close the model sheet
  }

  Future<void> _pickImageFromCamera() async {
    final returnImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  Future<Uint8List> generateInvoicePdf(
      String companyName,
      String companyLogoUrl,
      String companyPhoneNumber,
      String companyAddress,
      String clientName,
      List<Map<String, dynamic>> orderDetails,
      ) async {
    final pdf = pw.Document(); // Use pw.Document for PDF generation

    Future<pw.ImageProvider?> getImageFromUrl(String url) async {
      try {
        final ByteData? imageData = await rootBundle.load(url);
        if (imageData != null) {
          final Uint8List bytes = Uint8List.view(imageData.buffer);
          return pw.MemoryImage(bytes);
        }
      } catch (e) {
        print('Error loading image from URL: $e');
      }
      return null; // Return null if loading fails
    }

    // Get company logo image from URL
    final pw.ImageProvider? companyLogo = await getImageFromUrl(companyLogoUrl);

    if (companyLogo == null) {
      throw Exception('Failed to load company logo image');
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(companyName, textScaleFactor: 1.5),
                      pw.Text('Phone: $companyPhoneNumber'),
                      pw.Text(companyAddress),
                    ],
                  ),
                  if (companyLogo != null)
                    pw.Container(
                      width: 100, // Adjust width as needed
                      height: 100, // Adjust height as needed
                      child: pw.Image(companyLogo),
                    ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Client: $clientName'),
                  pw.Text('Date: ${DateTime.now().toString()}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                data: <List<String>>[
                  <String>['No.', 'Item Image', 'Description', 'Amount'],
                  for (var order in orderDetails) ...[
                    [
                      (orderDetails.indexOf(order) + 1).toString(),
                      order['imageURL'] != null
                          ? Image.network(order['imageURL'] as String) // Load image from imageURL if available
                          : AssetImage('path_to_placeholder_image'), // Use a placeholder image if imageURL is null
                      order['description']?.toString() ?? '', // Ensure description is treated as a string, handle null values
                      '\$${(double.parse(order['designCharge'] ?? '0') + double.parse(order['rptCharge'] ?? '0') + double.parse(order['otherCharge'] ?? '0')).toStringAsFixed(2)}',
                    ].map<String>((e) => e.toString()).toList(), // Convert each element to a string
                  ],
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: \$${orderDetails.fold<double>(
                    0,
                        (sum, order) => sum +
                        double.parse(order['designCharge'] ?? '0') +
                        double.parse(order['rptCharge'] ?? '0') +
                        double.parse(order['otherCharge'] ?? '0'),
                  ).toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // Save PDF to bytes
    return pdf.save();
  }
}