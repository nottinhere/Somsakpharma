import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somsakpharma/models/product_all_model.dart';
import 'package:somsakpharma/models/promote_model.dart';
import 'package:somsakpharma/models/user_model.dart';
import 'package:somsakpharma/scaffold/authen.dart';
import 'package:somsakpharma/scaffold/detail.dart';
import 'package:somsakpharma/scaffold/detail_cart.dart';

import 'package:somsakpharma/scaffold/list_product.dart';
import 'package:somsakpharma/utility/my_style.dart';
import 'package:somsakpharma/utility/normal_dialog.dart';

class Home extends StatefulWidget {
  final UserModel userModel;

  Home({Key key, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Explicit
  // List<PromoteModel> promoteModels = List();
  List<Widget> promoteLists = List();
  List<Widget> suggestLists = List();
  List<String> urlImages = List();
  List<String> urlImagesSuggest = List();

  int amontCart = 0, banerIndex = 0, suggessIndex = 0;
  UserModel myUserModel;
  List<ProductAllModel> promoteModels = List();
  List<ProductAllModel> suggestModels = List();
  String qrString;
  // Method
  @override
  void initState() {
    super.initState();
    readPromotion();
    myUserModel = widget.userModel;
    readSuggest();
  }

  Future<void> readPromotion() async {
    String url = 'http://www.somsakpharma.com/api/json_promotion.php';
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        promoteModels.add(productAllModel);
        promoteLists.add(showImageNetWork(urlImage));
        urlImages.add(urlImage);
      });
    }
  }

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  Future<void> readSuggest() async {
    String memId = myUserModel.id;
    String url =
        'http://www.somsakpharma.com/api/json_suggest.php?memberId=$memId'; // ?memberId=$memberId
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        suggestModels.add(productAllModel);
        suggestLists.add(Image.network(urlImage));
        urlImagesSuggest.add(urlImage);
      });
    }
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showCarouseSlider() {
    return GestureDetector(
      onTap: () {
        print('You Click index is $banerIndex');

        MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) => Detail(
            productAllModel: promoteModels[banerIndex],
            userModel: myUserModel,
          ),
        );
        // Navigator.of(context).push(route).then((value) {});  //  link to detail page
      },
      child: CarouselSlider(
        height: 1200,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        pauseAutoPlayOnTouch: Duration(seconds: 5),
        autoPlay: true,
        autoPlayAnimationDuration: Duration(seconds: 5),
        items: promoteLists,
        onPageChanged: (int index) {
          banerIndex = index;
          // print('index = $index');
        },
      ),
    );
  }

  Widget showCarouseSliderSuggest() {
    return GestureDetector(
      onTap: () {
        print('You Click index is $suggessIndex');

        MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) => Detail(
            productAllModel: suggestModels[suggessIndex],
            userModel: myUserModel,
          ),
        );
        Navigator.of(context).push(route).then((value) {});
      },
      child: CarouselSlider(
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        pauseAutoPlayOnTouch: Duration(seconds: 5),
        autoPlay: true,
        autoPlayAnimationDuration: Duration(seconds: 5),
        items: suggestLists,
        onPageChanged: (int index) {
          suggessIndex = index;
          // print('index = $index');
        },
      ),
    );
  }

  Widget promotion() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        height: MediaQuery.of(context).size.width * 0.70, // size.height * 0.20,
        child: promoteLists.length == 0
            ? myCircularProgress()
            : showCarouseSlider(),
      ),
    );
  }

  Widget suggest() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: suggestLists.length == 0
            ? myCircularProgress()
            : showCarouseSliderSuggest(),
      ),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget productBox() {
    String login = myUserModel.name;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.greenAccent.shade100, // Colors.grey.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_drugs.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  'รายการสินค้า',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click product');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget orderhistoryBox() {
    String login = myUserModel.name;
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.greenAccent.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_drugs.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  'ประวัติการสั่งซื้อ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click product');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget topLeft() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_drugs.png'),
                ),
                Text(
                  'รายการสินค้า',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget topRight() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_cart.png'),
                ),
                Text(
                  'ตะกร้าสินค้า',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click newproduct');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return DetailCart(
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget bottomLeft() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_barcode.png'),
                ),
                Text(
                  'Barcode scan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click barcode scan');
          readQRcode();
         // Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget bottomRight() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_recommend.png'),
                ),
                Text(
                  'Recommend',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click recommend');
          routeToListProduct(3);
        },
      ),
    );
  }

/*
  Widget productMenu() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade100,
          child: Container(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'recommend',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          print('You click recommend');
          routeToListProduct(3);
        },
      ),
    );
  }
*/
  Widget bottomMenu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        bottomLeft(),
        // bottomRight(),
      ],
    );
  }

  Widget topMenu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        topLeft(),
        topRight(),
      ],
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
    );
  }

  Widget menuReadQRcode() {
    return ListTile(
      leading: Icon(
        Icons.photo_camera,
        size: 36.0,
      ),
      title: Text('Read QR code'),
      subtitle: Text('Read QR code or barcode'),
      onTap: () {
        readQRcode();
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> readQRcode() async {
    try {
      qrString = await BarcodeScanner.scan();
      print('QR code = $qrString');
      if (qrString != null) {
        decodeQRcode(qrString);
      }
    } catch (e) {
      print('e = $e');
    }
  }

  Future<void> decodeQRcode(String code) async {
    try {
      String url = 'http://somsakpharma.com/api/json_product.php?bqcode=$code';
      http.Response response = await http.get(url);
      var result = json.decode(response.body);
      print('result ===*******>>>> $result');

      int status = result['status'];
      print('status ===>>> $status');
      if (status == 0) {
        normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
      } else {
        var itemProducts = result['itemsProduct'];
        for (var map in itemProducts) {
          print('map ===*******>>>> $map');

          ProductAllModel productAllModel = ProductAllModel.fromJson(map);
          MaterialPageRoute route = MaterialPageRoute(
            builder: (BuildContext context) => Detail(
              userModel: myUserModel,
              productAllModel: productAllModel,
            ),
          );
          Navigator.of(context).push(route).then((value) {
            setState(() {
              // readCart();
            });
          });
        }
      }
    } catch (e) {}
  }

  Widget homeMenu() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      // color: Colors.green.shade50,
      // height: MediaQuery.of(context).size.height * 0.5 - 81,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          topMenu(),
          // mySizebox(),
          bottomMenu(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          headTitle('สินค้าแนะนำ', Icons.thumb_up),
          suggest(),
          headTitle('เมนู', Icons.home),
          homeMenu(),
          // productBox(),
          // orderhistoryBox(),
          headTitle('สินค้าโปรโมชัน', Icons.bookmark),
          promotion(),
        ],
      ),
    );
  }

  Widget headTitle(String string, IconData iconData) {
    // Widget  แทน object ประเภทไดก็ได้
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            size: 24.0,
            color: MyStyle().textColor,
          ),
          mySizebox(),
          Text(
            string,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyStyle().textColor,
            ),
          ),
        ],
      ),
    );
  }
}
