import 'package:flutter/material.dart';

Widget couter(screenHeight, String text, int number) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: const Color.fromARGB(220, 255, 255, 255),
            fontSize: screenHeight * 0.14,
            fontStyle: FontStyle.italic,
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(
        width: 2,
      ),
      RotatedBox(
        quarterTurns: 1,
        child: Text(
          "        $text",
          style: TextStyle(
            color: const Color.fromARGB(220, 255, 255, 255),
            fontSize: screenHeight * 0.018,
            fontStyle: FontStyle.italic,
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
          ),
        ),
      )
    ],
  );
}

Widget test(screenHeight, double height, String text, int number) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: height + screenHeight * 0.15,
        ),
        couter(screenHeight, text, number),
      ],
    ),
  );
}


