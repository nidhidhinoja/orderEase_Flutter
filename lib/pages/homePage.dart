import 'package:flutter/material.dart';
import 'package:flutterapp/pages/menubarDrawer.dart';
import 'package:flutterapp/pages/orders.dart'; // Import your Orders page
import 'package:flutterapp/pages/clients.dart'; // Import your Clients page
import 'package:flutterapp/pages/invoice.dart'; // Import your Invoices page

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> catNames = [
    "Orders",
    "Invoices",
    "Clients",
    "Reports",
  ];

  final List<Color> catColors = [
    Color(0xFFFC7C7F),
    Color(0xFF6FE08D),
    Color(0xFFCB84FB),
    Color(0xFF61BDFD),
  ];

  final List<Icon> catIcons = [
    Icon(Icons.work, color: Colors.white, size: 25,),
    Icon(Icons.file_copy, color: Colors.white, size: 25,),
    Icon(Icons.people, color: Colors.white, size: 25,),
    Icon(Icons.money, color: Colors.white, size: 25,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      icon: Icon(
                        Icons.dashboard,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.notifications,
                      size: 30,
                      color: Colors.white,
                    )
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 3, bottom: 15),
                  child: Text(
                    "Hi, Designer",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      wordSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search here...",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                catIcons.length,
                    (index) => InkWell(
                  onTap: () {
                    // Navigate to respective pages
                    switch (index) {
                      case 0:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Orders()),
                        );
                        break;
                      case 1:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Invoices()),
                        );
                        break;
                      case 2:
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Clients()),
                        );
                        break;
                    // Handle other cases if needed
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: catColors[index],
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: catIcons[index]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        catNames[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20), // Added spacing between category icons and current orders
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Current Orders",
                    style : TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                    )
                ),
                Text(
                    "See all",
                    style : TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.blue.withOpacity(0.7),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: MenuBarDrawer(),
    );
  }
}
