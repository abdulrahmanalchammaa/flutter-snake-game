import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SnakeApp extends StatefulWidget {
  const SnakeApp({Key? key}) : super(key: key);

  @override
  State<SnakeApp> createState() => _SnakeAppState();
}

class _SnakeAppState extends State<SnakeApp> {
  final int dotRow = 20;
  final int dotCol = 40;

  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);

  final randomGen = Random();

  var snake = [
    [0, 1],
    [0, 0]
  ];
  var food = [0, 2];

  var direction = 'up';

  var isPlaying = false;

  void startGame() {
    const duration = Duration(milliseconds: 300);

    snake = [
      [(dotRow / 2).floor(), (dotCol / 2).floor()]
    ];

    snake.add([snake.first[0], snake.first[1] - 1]);

    createFood();

    isPlaying = true;
    Timer.periodic(duration, (Timer timer) {
      moveSnake();
      if (checkGameOver()) {
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case 'up':
          snake.insert(0, [snake.first[0], snake.first[1] - 1]);
          break;
        case 'down':
          snake.insert(0, [snake.first[0], snake.first[1] + 1]);
          break;
        case 'left':
          snake.insert(0, [snake.first[0] - 1, snake.first[1]]);
          break;
        case 'right':
          snake.insert(0, [snake.first[0] + 1, snake.first[1]]);
          break;
      }

      if (snake.first[0] != food[0] || snake.first[1] != food[1]) {
        snake.removeLast();
      } else {
        createFood();
      }
    });
  }

  void createFood() {
    food = [
      randomGen.nextInt(dotRow),
      randomGen.nextInt(dotCol)
    ];
  }

  bool checkGameOver() {
    if (!isPlaying ||
        snake.first[1] < 0 ||
        snake.first[1] >= dotCol ||
        snake.first[0] < 0 ||
        snake.first[0] > dotRow) {
      return true;
    }

    for (var i = 1; i < snake.length; ++i) {
      if (snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]) {
        return true;
      }
    }
    return false;
  }

  void endGame() {
    isPlaying = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text(
            'Score: ${snake.length - 2}',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpeg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                child: AspectRatio(
                  aspectRatio: dotRow / (dotCol + 5),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: dotRow,
                    ),
                    itemCount: dotRow * dotCol,
                    itemBuilder: (BuildContext context, int index) {
                      var color;
                      var shape;
                      var x = index % dotRow;
                      var y = (index / dotRow).floor();

                      bool isSnakeBody = false;
                      for (var pos in snake) {
                        if (pos[0] == x && pos[1] == y) {
                          isSnakeBody = true;
                          break;
                        }
                      }
                      if (snake.first[0] == x && snake.first[1] == y) {
                        color = Colors.blue;
                        shape = BoxShape.rectangle;
                      } else if (isSnakeBody) {
                        color = Colors.lightBlue[200];
                        shape = BoxShape.rectangle;
                      } else if (food[0] == x && food[1] == y) {
                        color = Colors.red;
                        shape = BoxShape.circle;
                      } else {
                        color = Colors.purple[800];
                        shape = BoxShape.rectangle;
                      }

                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: shape,
                        ),
                      );
                    },
                  ),
                ),
                onVerticalDragUpdate: ((details) {
                  if (direction != 'up' && details.delta.dy > 0) {
                    direction = 'down';
                  } else if (direction != 'down' && details.delta.dy < 0) {
                    direction = 'up';
                  }
                }),
                onHorizontalDragUpdate: ((details) {
                  if (direction != 'left' && details.delta.dx > 0) {
                    direction = 'right';
                  } else if (direction != 'right' && details.delta.dx < 0) {
                    direction = 'left';
                  }
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          return isPlaying ? Colors.red : Colors.green;
                        },
                      ),
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        isPlaying = false;
                      } else {
                        startGame();
                      }
                    },
                    child: Text(
                      isPlaying ? 'Stop' : 'Start',
                      style: fontStyle,
                    ),
                  ),
                  Text(
                    'Score: ${snake.length - 2}',
                    style: fontStyle,
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

