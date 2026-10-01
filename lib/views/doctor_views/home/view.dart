
import 'package:flutter/material.dart';

class DocHomeView extends StatefulWidget {
  const DocHomeView({super.key});

  @override
  State<DocHomeView> createState() => _DocHomeViewState();
}

class _DocHomeViewState extends State<DocHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("data"),
      ),
    );
  }
}
