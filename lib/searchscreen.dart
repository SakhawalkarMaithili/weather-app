import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String city = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Search'),
      ),
      body: Center(
          child: Column(
        children: [
          TextField(
            onChanged: (value) {
              // print(value);
              setState(() {
                city = value;
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: 'Search',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          CupertinoButton(
              color: Colors.white,
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                // print(city);
                Navigator.pop(context, city);
              })
        ],
      )),
    );
  }
}
