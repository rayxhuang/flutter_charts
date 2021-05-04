import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Op extends StatefulWidget {
  @override
  _OpState createState() => _OpState();
}

class _OpState extends State<Op> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.clear),
      onPressed: () { setState(() {
        i += 1;
      }); },
    );
  }
}
