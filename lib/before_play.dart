import 'package:first_page_test_0401/PlayerPage.dart';
import 'package:flutter/material.dart';
import 'dart:math';
class BeforePlay extends StatefulWidget {
  @override
  _BeforePlayState createState() => _BeforePlayState();
}

class _BeforePlayState extends State<BeforePlay> {
  late List<List<bool>> buttonStates;
  late List<List<String>> buttonText;
  var number = 1;
  bool isFilled = false;

  @override
  void initState() {
    super.initState();
    buttonStates = List.generate(5, (_) => List.filled(5, false));
    buttonText = List.generate(5, (_) => List.filled(5, ""));
  }

  Widget buildElevatedButton(int row, int col) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(65, 40),
        backgroundColor: buttonStates[row][col] ? Colors.red[300] : Colors.teal[400],
      ),
      onPressed: () {
        setState(() {
          if (!buttonStates[row][col]) {
            buttonStates[row][col] = true;
            if (number < 10) buttonText[row][col] += '0';
            buttonText[row][col] += number.toString();
            number++;
            if(number>25) isFilled = true;
          }
        });
      },
      child: Text(
        buttonText[row][col],
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override

  Widget build(BuildContext context) {
    var buttonSpacing = 5.0;
    final element = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;
    final String username = element['username'];
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
                visible : !isFilled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Welcome , ${username}',style: TextStyle(fontSize: 22.0)),
                    Text('Press buttom to fill the bingo card!',style: TextStyle(fontSize: 22.0)),
                    Text('Now number : ${number}',style: TextStyle(fontSize: 30.0)),
                  ],
                ),
            ),
            SizedBox(height: 100),
            Visibility(
              visible: isFilled,
              child:Text('Ready or not!',style: TextStyle(fontSize: 40.0)),
            ),
            SizedBox(height: 50),
            for (int row = 0; row < 5; row++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int col = 0; col < 5; col++)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: buttonSpacing),
                      child: buildElevatedButton(row, col),
                    ),
                ],
              ),
            SizedBox(height: 30),
            Visibility(
              visible: isFilled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PlayerPage(
                              username: username,
                              bingoCard: buttonText,
                            ),
                          ));
                        });
                      },
                      child: Text('Ready!',style: TextStyle(fontSize: 30.0)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        fixedSize:Size(400.0, 60.0),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          for(int i=0;i<5;i++){
                            for(int j=0;j<5;j++){
                              buttonStates[i][j] = false;
                              buttonText[i][j] = "";
                              number = 1;
                              isFilled = false;
                            }
                          }
                        });
                      },
                      child: Text('Reset the bingo card!',style: TextStyle(fontSize: 25.0)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black12,
                        fixedSize:Size(400.0, 60.0),
                      ),
                    ),
                  ]
              )
            ),
            Visibility(
              visible : !isFilled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        List<bool> tmp = List.generate(30, (index) => false);
                        Random random = new Random(); // 在循环外部声明随机数生成器
                        for (int i = 0; i < 5; i++) {
                          for (int j = 0; j < 5; j++) {
                            int randomNumber;
                            do {
                              randomNumber = random.nextInt(25) + 1;
                            } while (tmp[randomNumber - 1] == true);
                            tmp[randomNumber - 1] = true;
                            buttonText[i][j] = randomNumber.toString();
                            buttonStates[i][j] = true;
                          }
                        }
                        isFilled = true;
                      });
                    },
                    child: Text('random filled number',style: TextStyle(fontSize: 25.0)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      fixedSize:Size(400.0, 60.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
