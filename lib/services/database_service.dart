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

    // saving the userdata
  Future savingUserData(String fullName, String email) async {
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

    // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

    // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
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
  getGroupChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // getting group admin
  Future getGroupAdmin(String groupId) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot snapshot = await groupDocumentReference.get();
    return snapshot['admin'];
  }

  // getting group memebrs
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}


