import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:lottie/lottie.dart';

class PlayerPage extends StatefulWidget {
  final String username;
  final List<List<String>> bingoCard;

  PlayerPage({Key? key, required this.username, required this.bingoCard}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late IO.Socket socket;
  late List<List<bool>> buttonStates;
  late List<List<String>> buttonText;
  List<String> bingoNumbers = List.filled(6, " ");
  bool waiting = true;
  bool game_start = false;
  bool animate = false;
  bool win = false;
  bool end = false;
  String end_message = " ";
  @override
  void initState() {
    super.initState();
    buttonStates = List.generate(5, (_) => List.filled(5, false));
    buttonText = widget.bingoCard;
    connectToNode("player");
  }

  Widget buildElevatedButton(int row, int col) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(65, 40),
        backgroundColor: buttonStates[row][col] ? Colors.red[300] : Colors.teal[400],
      ),
      onPressed: () {
        setState(() {
          buttonStates[row][col] = !buttonStates[row][col];
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: waiting,
              child: Column(
                children: [
                  Container(
                    child: Text(
                      'Waiting host to start the game...',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Lottie.asset('assets/animation/b7.json'),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: game_start,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'The last five drawn numbers:', style: TextStyle(fontSize: 22.0),  textAlign: TextAlign.left,),
                  Row(
                    children: [
                      BingoBall(number: bingoNumbers[1]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[2]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[3]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[4]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[5]),
                    ],
                  ),
                  Container(
                    width: 400,
                    height: 10,
                    color: Colors.red,
                  ),
                  Text(
                    'NOW bingo numbers:', style: TextStyle(fontSize: 27.0),  textAlign: TextAlign.left,),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200), // 动画持续时间
                        curve: Curves.easeInOut,
                        transform: animate ? Matrix4.translationValues(0.0, -5.0, 0.0) : Matrix4.translationValues(0.0, 0.0, 0.0),
                        child: BingoBall(number: bingoNumbers[0]),
                      ),
                    ),
                  ),
                  SizedBox(height:60.0),
                  Text(
                    'Press the button to record',
                    style: TextStyle(fontSize: 27.0),
                  ),
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
                  ElevatedButton(
                    onPressed: () {
                      if(bingo_judge_is_win_or_not()){
                        socket.emit('player_has_bingo',widget.username);
                        setState(() {
                          win = true;
                        });
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You must have 3 lines to win the game'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                        'send BINGO to host',
                        style: TextStyle(fontSize: 30.0)
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      fixedSize: Size(400.0, 60.0),
                    ),
                  ),
                ],
              ),
            ),

            Visibility(
              visible: end,
              child: Column(
                  children: [
                    Text(
                        end_message,
                        style: TextStyle(fontSize: 30.0)
                    ),
                    Visibility(
                        visible: win,
                        child:Column(
                            children: [
                              Lottie.asset('assets/animation/cele.json'),
                              Text("You're the winner",style:
                              TextStyle(fontSize: 30.0,color:Colors.red)
                              ),
                              Text("Congratulations!",style:
                              TextStyle(fontSize: 30.0,color:Colors.red)
                              )
                            ]
                        )
                    ),
                  ]
              )
            ),
          ],
        ),
      ),
    );
  }

  bool bingo_judge_is_win_or_not() {
    List<bool> is_line = List.generate(12, (index) => true);
    for(int i=0;i<5;i++){
      if(buttonStates[i][0]==false){
        is_line[0] = false;
      }
      if(buttonStates[i][1]==false){
        is_line[1] = false;
      }
      if(buttonStates[i][2]==false){
        is_line[2] = false;
      }
      if(buttonStates[i][3]==false){
        is_line[3] = false;
      }
      if(buttonStates[i][4]==false){
        is_line[4] = false;
      }
      if(buttonStates[0][i]==false){
        is_line[5] = false;
      }
      if(buttonStates[1][i]==false){
        is_line[6] = false;
      }
      if(buttonStates[2][i]==false){
        is_line[7] = false;
      }
      if(buttonStates[3][i]==false){
        is_line[8] = false;
      }
      if(buttonStates[4][i]==false){
        is_line[9] = false;
      }
      if(buttonStates[i][i]==false){
        is_line[10] = false;
      }
      if(buttonStates[i][4-i]==false){
        is_line[11] = false;
      }
    }
    int count_line = 0;
    for(int k=0;k<12;k++){
      if(is_line[k]) count_line++;
    }
    if(count_line>=3) return true;
    else return false;
  }

  void connectToNode(String who) {
    socket = IO.io('http://10.201.3.162:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'role': who},
    });

    socket.on('connect', (_) {
      print('Connected to Node.js server');
    });

    socket.on('startGame', (_) {
      setState(() {
        waiting = false;
        game_start = true;
      });
    });

    socket.on('message', (data) {
      print('Message from Node.js: $data');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from Node.js server');
    });

    socket.on('BingoNumber', (data) {
      print('Number: $data');
      setState(() {
        animate = true;
        Future.delayed(Duration(milliseconds: 200), () {
          setState(() {
            animate = false;
            bingoNumbers[5] = bingoNumbers[4];
            bingoNumbers[4] = bingoNumbers[3];
            bingoNumbers[3] = bingoNumbers[2];
            bingoNumbers[2] = bingoNumbers[1];
            bingoNumbers[1] = bingoNumbers[0];
            bingoNumbers[0] = data;
          });
        });
      });
    });
    socket.on('end_game', (data) {
      setState(() {
        game_start = false;
        end = true;
        end_message = "player ${data} has three lines";
      });
    });
  }
}


class BingoBall extends StatelessWidget {
  final String number;

  const BingoBall({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
