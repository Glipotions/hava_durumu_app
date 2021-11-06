import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? secilenSehir;
  final myController = TextEditingController();

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Geçersiz Giriş'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Lütfen Geçerli Bir Şehir Adı Giriniz.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/search.jpg'),
        )),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextField(
                    controller: myController,
                    decoration: const InputDecoration(
                        hintText: 'Şehir Seçiniz',
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                    style: TextStyle(
                      fontSize: 35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                FlatButton(
                    onPressed: () async {
                      var response = await http.get(Uri.https(
                          'www.metaweather.com', '/api/location/search/', {
                        'query': {myController.text}
                      }));
                      jsonDecode(response.body).isEmpty
                          ? _showMyDialog()
                          : Navigator.pop(context, myController.text);
                    },
                    child: const Text('Şehri Seç'))
              ],
            ),
          ),
        ));
  }
}
