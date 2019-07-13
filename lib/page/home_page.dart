import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _preco = '0.00';
  String _dataAtualizacao = '';

  Future _salvar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('preco', _preco);
    prefs.setString('data', _dataAtualizacao);
  }

  void _recuperarDados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _preco = (prefs.getString('preco') ?? '0.00');
      _dataAtualizacao = (prefs.getString('data') ?? '00/00/0000 às 00:00');
    });
  }

  void _atualizarData() {
    setState(() {
      _dataAtualizacao = formatDate(DateTime.now(),
          [dd, '/', mm, '/', yyyy, ' às ', HH, ':', nn, ':', ss]).toString();
    });
  }

  void _atualizarPreco() async {
    var url = 'https://blockchain.info/ticker';
    http.Response response = await http.get(url);
    Map<String, dynamic> retorno = json.decode(response.body);
    setState(() {
      _preco = retorno['BRL']['buy'].toString();
      _salvar();
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(_preco),
      bottomSheet: buildFooter(_dataAtualizacao),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text('Bitcoin'),
      backgroundColor: Colors.black,
      centerTitle: true,
    );
  }

  Widget buildBody(String preco) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/bitcoin-logo.png'),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                'R\$ $preco',
                style: TextStyle(fontSize: 35),
              ),
            ),
            buildButton('Atualizar'),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String texto) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        splashColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: Colors.black),
        ),
        child: Text(
          texto,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(30, 15, 30, 15),
        onPressed: () {
          _atualizarData();
          _atualizarPreco();
        },
      ),
    );
  }

  Widget buildFooter(String dataAtualizada) {
    return Container(
      color: Colors.black,
      width: double.maxFinite,
      height: 50,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Última atualização em $dataAtualizada',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
