import 'package:flutter/material.dart';
import 'package:flutterapp/pages/clients.dart';
import 'package:flutterapp/pages/invoice.dart';
import 'package:flutterapp/pages/orders.dart';
import 'package:flutterapp/pages/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterapp/pages/downloadInvoice.dart';

class MenuBarDrawer extends StatelessWidget {
  final String? clientId;

  const MenuBarDrawer({Key? key, this.clientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              image: DecorationImage(
                image: NetworkImage(
                  "https://t3.ftcdn.net/jpg/03/91/46/10/360_F_391461057_5P0BOWl4lY442Zoo9rzEeJU0S2c1WDZR.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: UserAccountsDrawerHeader(
              accountName: Text(
                'Nidhi Dhinoja',
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                'Nidhidhinoja@gmail.com',
                style: TextStyle(color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.network(
                    "https://media.sproutsocial.com/uploads/2022/06/profile-picture.jpeg",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.file_copy),
            title: Text("Orders"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Orders(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text("Clients"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Clients()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text("Invoice"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Invoices()),
              );
            },
          ),

          Divider(),
          ListTile(
            leading: Icon(Icons.money),
            title: Text("Income"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DownloadInvoice()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("History"),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text("Share"),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Log Out"),
            onTap: () async {
              // Sign out the user from Firebase Authentication
              await FirebaseAuth.instance.signOut();

              // Navigate to the WelcomePage after logging out
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
                    (route) => false, // Remove all existing routes
              );
            },
          ),
        ],
      ),
    );
  }
}
