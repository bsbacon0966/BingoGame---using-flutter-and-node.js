import 'package:flutter/material.dart';
import 'PlayerPage.dart';
import 'HostPage.dart';
import 'before_play.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFBBFAFA)),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              TextEditingController usernameController = TextEditingController();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_box_rounded,
                    size: 150,
                  ),
                  Text(
                    "BINGO  GAME",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 42.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Raleway',
                      letterSpacing: 2.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter your username',
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    child: const Text(
                      "Become a host",
                      style: TextStyle(fontSize: 25.0),
                    ),
                    onPressed: () {
                      if (usernameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter your username.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        String username = usernameController.text;
                        Map<String, dynamic> data = {
                          'username': username,
                        };
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HostPage(
                            username: username,
                          ),
                        ));
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(300.0, 60.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text(
                      "Become a player",
                      style: TextStyle(fontSize: 25.0),
                    ),
                    onPressed: () {
                      if (usernameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter your username.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        String username = usernameController.text;
                        Map<String, dynamic> data = {
                          'username': username,
                        };
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BeforePlay(),
                            settings: RouteSettings(
                              arguments: data,
                            ),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(300.0, 60.0),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


