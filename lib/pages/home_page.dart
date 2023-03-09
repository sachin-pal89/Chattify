import 'package:chattify/helper/helper_functions.dart';
import 'package:chattify/pages/auth/login_page.dart';
import 'package:chattify/pages/profile_page.dart';
import 'package:chattify/pages/search_page.dart';
import 'package:chattify/services/auth_service.dart';
import 'package:chattify/services/database_service.dart';
import 'package:chattify/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";

  // when the page is loaded all the info regarding user must be obtained
  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  // setting up user data
  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) => {
          setState(() {
            email = value!;
          })
        });

    await HelperFunctions.getUserNameFromSF().then((value) => {
          setState(() {
            userName = value!;
          })
        });

    // to get the groups data
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // to set a custom sized appbar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          // button to perform search
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(context, const SearchPage());
                },
                icon: const Icon(Icons.search))
          ],
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Chats",
            style: TextStyle(
                color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      // option to open a side drawer
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          // to add elements inside the drawer
          children: <Widget>[
            // Profile Image
            Icon(
              Icons.account_circle,
              size: 130,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            // Displaying Name of the user
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            // create a group menu
            ListTile(
              onTap: () {},
              // selected options has this color
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            // create a profile menu
            ListTile(
              onTap: () {
                // going to profile page
                nextScreenReplace(
                    context,
                    ProfilePage(
                      email: email,
                      userName: userName,
                    ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.account_circle),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            // create a logout menu
            ListTile(
              onTap: () async {
                // showing a dailog box
                showDialog(
                    // so that it does not vanish if we click somewhere else
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        // basically options button
                        actions: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                          IconButton(
                              onPressed: () async {
                                // signing out the current user
                                await authService.signOut();
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LogInPage()),
                                    (route) => false);
                              },
                              icon: const Icon(
                                Icons.exit_to_app,
                                color: Colors.green,
                              )),
                        ],
                      );
                    });
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title:
                  const Text("Logout", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
      // to display all groups joined by user
      body: groupList(),
      // add button to create a new group
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        child: FloatingActionButton(
          onPressed: () {
            popUpDailog(context);
          },
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  popUpDailog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Create a Group",
              textAlign: TextAlign.left,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : TextField(
                        onChanged: (val) {
                          setState(() {
                            groupName = val;
                          });
                        },
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (groupName != "") {
                    setState(() {
                      _isLoading = true;
                    });
                    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                        .createUserGroup(userName,
                            FirebaseAuth.instance.currentUser!.uid, groupName)
                        .whenComplete(() {
                      setState(() {
                        _isLoading = false;
                      });
                    });
                    Navigator.of(context).pop();
                    showSnackbar(
                        context, Colors.green, "Group Created successfully");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text("CREATE"),
              ),
            ],
          );
        });
  }

  // we show an list of groups joined by user
  groupList() {
    return StreamBuilder(
      stream: groups,
      // getting the snapshot of user i.e. info of the user
      builder: (context, AsyncSnapshot snapshot) {
        // performing some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return const Text("Hello Sachin");
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          // till data is fetched then show progress bar
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  // If User has not joined any group so show this widget
  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        // + button to add groups
        children: [
          GestureDetector(
            onTap: () {
              popUpDailog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not joined any group, tap on add icon to create a group or search from top search bar",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
