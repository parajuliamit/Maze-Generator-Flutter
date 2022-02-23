import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maze_generation/constants.dart';

import '../models/cell.dart';

class MazeGenerator extends StatefulWidget {
  const MazeGenerator({Key? key}) : super(key: key);

  @override
  State<MazeGenerator> createState() => _MazeGeneratorState();
}

class _MazeGeneratorState extends State<MazeGenerator> {
  late List<Cell> cells;
  late final Timer _timer;
  late int _currentStep;
  final row = height ~/ spacing;
  final cols = width ~/ spacing;
  final List<Cell> stack = [];
  bool _isCompleted = false;
  bool _isWin = false;

  List<Cell> getCells() {
    List<Cell> cells = [];
    for (int i = 0; i < row; i++) {
      for (int j = 0; j < cols; j++) {
        cells.add(Cell(j, i));
      }
    }
    return cells;
  }

  int? getIndex(int i, int j) {
    if (i < 0 || j < 0 || i > row - 1 || j > cols - 1) {
      return null;
    }
    return i + (j * (width ~/ spacing));
  }

  List<Cell> checkNeighbours(Cell cell) {
    List<Cell> neighbours = [];
    int? top = getIndex(cell.i, cell.j - 1);
    int? bottom = getIndex(cell.i, cell.j + 1);
    int? left = getIndex(cell.i - 1, cell.j);
    int? right = getIndex(cell.i + 1, cell.j);
    if (top != null && !cells[top].visited) {
      neighbours.add(cells[top]);
    }
    if (right != null && !cells[right].visited) {
      neighbours.add(cells[right]);
    }
    if (bottom != null && !cells[bottom].visited) {
      neighbours.add(cells[bottom]);
    } else if (left != null && !cells[left].visited) {
      neighbours.add(cells[left]);
    }
    return neighbours;
  }

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    stack.clear();
    _isCompleted = false;
    _isWin = false;
    cells = getCells();
    _currentStep = 0;
    cells[_currentStep].visited = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), updateCell);
  }

  void updateCell(Timer timer) {
    for (int i = 0; i < 15; i++) {
      var neighbours = checkNeighbours(cells[_currentStep]);
      if (neighbours.isEmpty) {
        if (stack.isNotEmpty) {
          var lastCell = stack.removeLast();
          // setState(() {
          _currentStep = getIndex(lastCell.i, lastCell.j)!;
          // });
        } else {
          _timer.cancel();
          // setState(() {
          _isCompleted = true;
          // });
        }
      } else {
        var random = Random().nextInt(neighbours.length);
        var next = neighbours[random];
        stack.add(cells[_currentStep]);
        // setState(() {
        next.visited = true;
        removeWalls(cells[_currentStep], next);
        // });
        _currentStep = getIndex(next.i, next.j)!;
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  removeWalls(Cell current, Cell next) {
    if (current.j - next.j == 1) {
      current.left = false;
      next.right = false;
    } else if (current.j - next.j == -1) {
      current.right = false;
      next.left = false;
    } else if (current.i - next.i == 1) {
      current.top = false;
      next.bottom = false;
    } else if (current.i - next.i == -1) {
      current.bottom = false;
      next.top = false;
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (!_isCompleted || _isWin) {
      return;
    }
    setState(() {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          !cells[_currentStep].top) {
        _currentStep =
            getIndex(cells[_currentStep].i - 1, cells[_currentStep].j)!;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          !cells[_currentStep].bottom) {
        _currentStep =
            getIndex(cells[_currentStep].i + 1, cells[_currentStep].j)!;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          !cells[_currentStep].left) {
        _currentStep =
            getIndex(cells[_currentStep].i, cells[_currentStep].j - 1)!;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          !cells[_currentStep].right) {
        _currentStep =
            getIndex(cells[_currentStep].i, cells[_currentStep].j + 1)!;
      }
    });
    if (_currentStep == cells.length - 1) {
      setState(() {
        _isWin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: _handleKeyEvent,
          child: SafeArea(
            child: Center(
                child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height,
                    width: width,
                    child: Stack(
                      children: List.generate(
                        cells.length,
                        (index) => Positioned(
                          top: cells[index].x,
                          left: cells[index].y,
                          child: Container(
                              height: spacing,
                              width: spacing,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: cells[index].right
                                      ? const BorderSide(
                                          color: Colors.white, width: 1)
                                      : BorderSide.none,
                                  bottom: cells[index].bottom
                                      ? const BorderSide(
                                          color: Colors.white, width: 1)
                                      : BorderSide.none,
                                  left: cells[index].left
                                      ? const BorderSide(
                                          color: Colors.white, width: 1)
                                      : BorderSide.none,
                                  top: cells[index].top
                                      ? const BorderSide(
                                          color: Colors.white, width: 1)
                                      : BorderSide.none,
                                ),
                                color: index == _currentStep && _isCompleted
                                    ? Colors.blue.shade800.withOpacity(0.7)
                                    // : cells[index].visited
                                    //     ? Colors.purple.withOpacity(0.5)
                                    : Colors.transparent,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: index == 0
                                    ? const Text(
                                        'Start',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      )
                                    : index == cells.length - 1
                                        ? const Text(
                                            'End',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          )
                                        : null,
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    _isWin
                        ? 'You Win !!'
                        : _isCompleted
                            ? 'Maze Generation Completed'
                            : 'Generating Maze...',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  _isWin
                      ? MaterialButton(
                          elevation: 0,
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              reset();
                            });
                          },
                          child: const Text(
                            'Generate Another Maze',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        )
                      : _isCompleted
                          ? const Text(
                              'Press arrow keys to play.',
                              style: TextStyle(color: Colors.white),
                            )
                          : const SizedBox(),
                  Visibility(
                    visible: _isCompleted &&
                        !_isWin &&
                        MediaQuery.of(context).size.height >
                            MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        FloatingActionButton(
                          onPressed: () {},
                          child: const Icon(Icons.keyboard_arrow_up),
                        ),
                        Row(
                          children: [
                            FloatingActionButton(
                              onPressed: () {},
                              child: const Icon(Icons.keyboard_arrow_up),
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                            FloatingActionButton(
                              onPressed: () {},
                              child: const Icon(Icons.keyboard_arrow_right),
                            ),
                          ],
                        ),
                        FloatingActionButton(
                          onPressed: () {},
                          child: const Icon(Icons.keyboard_arrow_up),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ),
        ));
  }
}
