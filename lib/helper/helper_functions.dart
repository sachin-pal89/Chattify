import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //keys
  static String userLoggedInKey = "UserLoggedInKey";
  static String userNameKey = "UserNameKey";
  static String userEmailKey = "UserEmailKey";

  // saving data for SF

  // getting data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }
}
