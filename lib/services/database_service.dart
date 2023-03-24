import "package:cloud_firestore/cloud_firestore.dart";

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections

  // reference for users collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  // reference for groups collections
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // updating the userdata
  Future updateUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "groups": [],
      "profilePic": "",
      "uid": uid,
    });
  }

  // getting the userdata
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // getting user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating groups
  Future createUserGroup(String userName, String id, String groupName) async {
    // creating the group first time
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "memebers": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": ""
    });

    // updating the group info
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id
    });

    // updating the user groups info
    DocumentReference userDocumentReference = userCollection.doc(uid);

    // giving grp name as groupId + groupname
    await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"]),
    });
  }
  
  // getting groups chat
  getGroupChats(String groupId) async{
    return groupCollection
          .doc(groupId)
          .collection("messages")
          .orderBy("time")
          .snapshots();
  }

  // getting group admin
  Future getgroupAdmin(String groupId) async {
      DocumentReference groupDocumentReference = groupCollection.doc(groupId);
      DocumentSnapshot snapshot = await groupDocumentReference.get();
      return snapshot['admin'];
  }
}
