import 'package:chattify/pages/auth/login_page.dart';
import 'package:chattify/services/auth_service.dart';
import 'package:chattify/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        child: const Text("LOGOUT"),
        onPressed: () {
          authService.signOut();
          nextScreenReplace(context, const LogInPage());
        },
      )),
    );
  }
}
