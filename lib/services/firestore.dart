import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreService {
  final CollectionReference clientsCollection =
      FirebaseFirestore.instance.collection('clients');
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');
  final CollectionReference invoicesCollection =
      FirebaseFirestore.instance.collection('invoices');

  Stream<QuerySnapshot> getClientsStream() {
    return clientsCollection.snapshots();
  }

  Stream<QuerySnapshot> getOrdersStream({String? clientId}) {
    if (clientId != null) {
      return ordersCollection
          .where('clientId', isEqualTo: clientId)
          .snapshots();
    } else {
      return ordersCollection.snapshots(); // Return all orders
    }
  }


  Stream<QuerySnapshot> getInvoicesStream({String? clientId}) {
    if (clientId != null) {
      return invoicesCollection
          .where('clientId', isEqualTo: clientId)
          .snapshots();
    } else {
      return invoicesCollection.snapshots(); // Return all invoices
    }
  }

  Future<void> addClient(String name, String phoneNumber, String city) async {
    await clientsCollection.add({
      'name': name,
      'phoneNumber': phoneNumber,
      'city': city,
    });
  }

  Future<void> updateClient(
      String docID, String name, String phoneNumber, String city) async {
    await clientsCollection.doc(docID).update({
      'name': name,
      'phoneNumber': phoneNumber,
      'city': city,
    });
  }

  Future<void> deleteClient(String docID) async {
    await clientsCollection.doc(docID).delete();
  }

  Future<void> addOrder(
      String name, String description, String clientId) async {
    try {
      await ordersCollection.add({
        'name': name,
        'description': description,
        'clientId': clientId, // Assuming clientId is required for an order
        // Add any other fields if necessary
      });
    } catch (e) {
      print("Error adding order: $e");
    }
  }

  Future<void> updateOrder(
      String orderId, String name, String description) async {
    await ordersCollection.doc(orderId).update({
      'name': name,
      'description': description,
    });
  }

  Future<void> deleteOrder(String orderId) async {
    await ordersCollection.doc(orderId).delete();
  }


  Future<void> deleteInvoice(String invoiceId) async {
    await invoicesCollection.doc(invoiceId).delete();
  }

  Future<QuerySnapshot> getClientsSnapshot() async {
    return await clientsCollection.get();
  }

  Future<void> addInvoice(
      String name,
      String description,
      String clientId,
      List<String> orderIds,
      String? imageFilePath,
      String designCharge,
      String rptCharge,
      String otherCharge,
      ) async {
    try {
      final DocumentReference invoiceDocRef = await invoicesCollection.add({
        'name': name,
        'description': description,
        'clientId': clientId,
        'orderIds': orderIds,
        'imageFilePath': imageFilePath,
        'designCharge': designCharge,
        'rptCharge': rptCharge,
        'otherCharge': otherCharge,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // If an image is provided, upload it to storage and update the document with the image URL
      if (imageFilePath != null) {
        final String imageURL = await uploadImage(invoiceDocRef.id, imageFilePath);
        await invoiceDocRef.update({'imageURL': imageURL});
      }
    } catch (e) {
      print("Error adding invoice: $e");
      throw e; // Throw the error to handle it elsewhere if needed
    }
  }


  Future<String> uploadImage(String invoiceId, String imageFilePath) async {
    try {
      final reference = FirebaseStorage.instance
          .ref()
          .child('invoices')
          .child('$invoiceId.jpg'); // Choose a suitable file extension
      final task = reference.putFile(File(imageFilePath));

      final snapshot = await task.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // Return empty string on error
    }
  }

  Future<Map<String, dynamic>> getClientName(String clientId) async {
    try {
      final clientDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(clientId)
          .get();

      if (clientDoc.exists) {
        return clientDoc.data() as Map<String, dynamic>;
      } else {
        return {}; // Return an empty map if the client document does not exist
      }
    } catch (e) {
      print('Error fetching client details: $e');
      return {}; // Return an empty map on error
    }
  }

  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (orderDoc.exists) {
        return orderDoc.data() as Map<String, dynamic>;
      } else {
        return {}; // Return an empty map if the order document does not exist
      }
    } catch (e) {
      print('Error fetching order details: $e');
      return {}; // Return an empty map on error
    }
  }
}
