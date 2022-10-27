import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:somsakpharma/models/product_all_model.dart';
import 'package:somsakpharma/models/product_all_model2.dart';
import 'package:somsakpharma/models/unit_size_model.dart';
import 'package:somsakpharma/models/user_model.dart';
import 'package:somsakpharma/scaffold/detail_cart.dart';
import 'package:somsakpharma/utility/my_style.dart';
import 'package:somsakpharma/utility/normal_dialog.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:somsakpharma/models/promote_model.dart';

class Detail extends StatefulWidget {
  final ProductAllModel productAllModel;
  final UserModel userModel;

  Detail({Key key, this.productAllModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Explicit
  ProductAllModel currentProductAllModel;
  ProductAllModel2 productAllModel;
  List<UnitSizeModel> unitSizeModels = List();
  List<int> amounts = [
    1,
    0,
    0
  ]; // amount[0] -> s,amount[1] -> m,amount[2] -> l;
  int amontCart = 0;
  UserModel myUserModel;
  String id; // productID

  // String qtyS = '', qtyM = '', qtyL = '';
  int sizeSincart = 0, sizeMincart = 0, sizeLincart = 0;
  int qtyS = 0, qtyM = 0, qtyL = 0;
  int showSincart = 0, showMincart = 0, showLincart = 0;
  // var showSincart = '', showMincart = '', showLincart = '';

  List<Widget> promoteLists = List();
  List<Widget> relateLists = List();
  List<String> urlImages = List();
  List<String> urlImagesRelate = List();
  List<String> productsName = List();
  List<ProductAllModel> promoteModels = List();
  List<ProductAllModel> relateModels = List();
  int banerIndex = 0, relateIndex = 0;
  int currentIndex = 1;

  // Method
  @override
  void initState() {
    super.initState();
    currentProductAllModel = widget.productAllModel;
    myUserModel = widget.userModel;
    setState(() {
      getProductWhereID();
      readCart();
    });
    readRelate();
  }

  Future<void> getProductWhereID() async {
    if (currentProductAllModel != null) {
      String memberId = myUserModel.id.toString();
      id = currentProductAllModel.id.toString();
      String url = '${MyStyle().getProductWhereId}$id&memberId=$memberId';
      print('url Detaillll ====>>> $url');
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('result =0000000>>> $result');

      var itemProducts = result['itemsProduct'];
      print('itemProducts ===>>>>$itemProducts');
      for (var map in itemProducts) {
        print('map DEtail ==========>>>>>>>> $map');

        setState(() {
          productAllModel = ProductAllModel2.fromJson(map);

          Map<String, dynamic> priceListMap = map['price_list'];
          print('priceListMap = $priceListMap');

          Map<String, dynamic> sizeSmap = priceListMap['s'];
          if (sizeSmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeSmap);
            unitSizeModels.add(unitSizeModel);
          }
          Map<String, dynamic> sizeMmap = priceListMap['m'];
          if (sizeMmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeMmap);
            unitSizeModels.add(unitSizeModel);
          }
          Map<String, dynamic> sizeLmap = priceListMap['l'];
          if (sizeLmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeLmap);
            unitSizeModels.add(unitSizeModel);
          }

          print('sizeSmap = $sizeSmap');
          print('sizeMmap = $sizeMmap');
          print('sizeLmap = $sizeLmap');
          // print('unitSizeModel = ${unitSizeModels[0].lable}');
        });
      } // for
      setState(() {
        showSincart = productAllModel.itemincartSunit;
        showMincart = productAllModel.itemincartMunit;
        showLincart = productAllModel.itemincartLunit;
      });
    }
  }

  Future<void> readRelate() async {
    String memId = myUserModel.id;
    id = currentProductAllModel.id.toString();

    String url =
        'http://www.somsakpharma.com/api/json_relate.php?productId=$id'; // ?memberId=$memberId

    print('URL relate >> $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      String productName = promoteModel.title;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        relateModels.add(productAllModel);
        relateLists.add(Image.network(urlImage));
        urlImagesRelate.add(urlImage);
        productsName.add(productName);
      });
    }
  }

  Widget showCarouseSliderRelate() {
    return GestureDetector(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
        ),
        itemCount: (relateModels.length / 2).round(),
        itemBuilder: (context, index, realIdx) {
          final int first = index * 2;
          final int second = first + 1;

          return Row(
            children: [first, second].map((idx) {
                  return Expanded(
                    child: GestureDetector(
                      child: Card(
                        // flex: 1,
                        child: Column(
                          children: <Widget>[
                            Container(
                              // width: MediaQuery.of(context).size.width * 0.50,
                              height: 100.00,
                              child: relateLists[idx],
                              padding: EdgeInsets.all(8.0),
                            ),
                            Text(
                              productsName[idx].toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        print('You Click index >> $idx');
                        MaterialPageRoute route = MaterialPageRoute(
                          builder: (BuildContext context) => Detail(
                            productAllModel: relateModels[idx],
                            userModel: myUserModel,
                          ),
                        );
                        Navigator.of(context).push(route).then((value) {});
                      },
                    ),
                  );
                }).toList() ??
                [],
          );
        },
      ),
    );
  }

  Widget showImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 - 50,
      child: Image.network(
        productAllModel.photo,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget showTitle() {
    return Text(
      productAllModel.title,
      style: MyStyle().h2Style,
    );
  }

  Widget showDetail() {
    return Text(productAllModel.detail);
  }

  Widget showPackage(int index) {
    return Text(
      unitSizeModels[index].lable,
      style: MyStyle().h2Style,
    );
  }

  Widget showPricePackage(int index) {
    return Text(
      '${unitSizeModels[index].price.toString()} บาท/ ',
      style: MyStyle().h2Style,
    );
  }

  Widget showChoosePricePackage(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        showDetailPrice(index),
        // incDecValue(index),
        showValue(index),
      ],
    );
  }

  Widget showValue(int index) {
    // int value = amounts[index];
    //  return Text('$value');
    // var iniValue = '';
    int iniValue = 0;
    bool readOnlyMode;
    var iconName;
    var iconColor;
    // print('$sizeSincart / $sizeMincart / $sizeLincart ');
    if (index == 0)
      iniValue = showSincart;
    else if (index == 1)
      iniValue = showMincart;
    else if (index == 2) iniValue = showLincart;
    /////////////////////////////////////////////////////////
    if (unitSizeModels[index].price.toString() == '0') {
      readOnlyMode = true;
      iconName = Icons.cancel;
      iconColor = Color.fromARGB(0xff, 0xff, 0x99, 0x99);
    } else {
      readOnlyMode = false;
      iconName = Icons.mode_edit;
      iconColor = Colors.grey;
    }

    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,
      width: MediaQuery.of(context).size.width * 0.48,
      padding: EdgeInsets.only(left: 20.0, right: 10.0),
      child: Column(
        children: <Widget>[
          // TextFormField(
          //   style: TextStyle(color: Colors.black),
          //   initialValue: '${iniValue}',
          //   // readOnly: (unitSizeModels[index].price == 0)?true:false,
          //   readOnly: readOnlyMode,
          //   keyboardType: TextInputType.number,
          //   onChanged: (value) {
          //     if (index == 0)
          //       qtyS = value;
          //     else if (index == 1)
          //       qtyM = value;
          //     else if (index == 2) qtyL = value;
          //   },
          //   decoration: InputDecoration(
          //     contentPadding: EdgeInsets.only(
          //       top: 6.0,
          //     ),
          //     prefixIcon: Icon(iconName, color: iconColor),
          //     // border: InputBorder.none,
          //     // hintText: 'ระบุจำนวน',
          //     hintStyle: TextStyle(color: iconColor),
          //   ),
          // ),
          Padding(
            child: SpinBox(
              min: 0,
              max: 10000,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(0),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                ),
              ),

              value: (iniValue)
                  .toDouble(), //(iniValue == 0) ? 0 : (iniValue).toInt(),
              onChanged: (changevalue) {
                if (index == 0) {
                  setState(() {
                    qtyS = (changevalue == 0) ? 0 : (changevalue).toInt();
                  });
                } else if (index == 1) {
                  setState(() {
                    qtyM = (changevalue == 0) ? 0 : (changevalue).toInt();
                  });
                } else if (index == 2) {
                  setState(() {
                    qtyL = (changevalue == 0) ? 0 : (changevalue).toInt();
                  });
                }
              },
              // decoration: InputDecoration(labelText: 'Decimals'),
            ),
            padding: const EdgeInsets.all(2),
          ),
        ],
      ),
    );
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showDetailPrice(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        showPricePackage(index),
        showPackage(index),
      ],
    );
  }

  Widget relate() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: relateLists.length == 0
            ? myCircularProgress()
            : showCarouseSliderRelate(),
      ),
    );
  }

  Widget decButton(int index) {
    int value = amounts[index];
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {
        // print('dec index $index');
        if (value == 0) {
          normalDialog(context, 'Cannot decrese', 'Because empty cart');
        } else {
          setState(() {
            value--;
            amounts[index] = value;
          });
        }
      },
    );
  }

  Widget incButton(int index) {
    int value = amounts[index];

    return IconButton(
      icon: Icon(Icons.add_circle_outline),
      onPressed: () {
        setState(() {
          // print('inc index $index');
          value++;
          amounts[index] = value;
        });
      },
    );
  }

  // Widget showValue(int value) {
  //   return Text('$value');
  // }

  Widget incDecValue(int index) {
    int value = amounts[index];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        decButton(index),
        showValue(value),
        incButton(index),
      ],
    );
  }

  Widget showPrice() {
    return Container(
      height: 70.0,
      // color: Colors.grey,
      child: ListView.builder(
        itemCount: unitSizeModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return showChoosePricePackage(index); // showDetailPrice(index);
        },
      ),
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
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

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://www.somsakpharma.com/api/json_loadmycart.php?memberId=$memberId';

    print('url Detail =====>>>>>>>> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    var thisproductID = id;
    for (var map in cartList) {
      var productID = map['id'].toString();

      if (productID == thisproductID) {
        if (map['price_list']['s'] != null) {
          var sizeSincart = int.parse(map['price_list']['s']['quantity']);
          setState(() {
            showSincart = sizeSincart;
          });
        }
        if (map['price_list']['m'] != null) {
          int sizeMincart = int.parse(map['price_list']['m']['quantity']);
          setState(() {
            showMincart = sizeMincart;
          });
        }
        if (map['price_list']['l'] != null) {
          int sizeLincart = int.parse(map['price_list']['l']['quantity']);
          setState(() {
            showLincart = sizeLincart;
          });
        }
      }

      setState(() {
        amontCart++;
      });
    }
    print('amontCart (detail page)=====>>>>>>>> $amontCart');
  }

  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/shopping_cart.png'),
            Text(
              ' $amontCart ',
              style: TextStyle(
                backgroundColor: Colors.orange.shade900,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          showCart(),
        ],
        backgroundColor: MyStyle().textColor,
        title: Text('ข้อมูลสินค้า'),
      ),
      body: productAllModel == null ? showProgress() : showDetailList(),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget addButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: MyStyle()
                      .mainColor, // Sets color for all the descendent ElevatedButtons
                ),
                // color: MyStyle().mainColor,
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  String productID = id;
                  String memberID = myUserModel.id.toString();

                  // int index = 0;
                  // List<bool> status = List();

                  // for (var object in unitSizeModels) {
                  //   if (amounts[index] == 0) {
                  //     status.add(true);
                  //   } else {
                  //     status.add(false);
                  //   }

                  //   index++;
                  // }

                  // bool sumStatus = true;
                  // if (status.length == 1) {
                  //   sumStatus = status[0];
                  // } else {
                  //   sumStatus = status[0] && status[1];
                  // }

                  // if (sumStatus) {
                  //   normalDialog(
                  //       context, 'Do not choose item', 'Please choose item');
                  // } else {
                  //   int index = 0;
                  //   for (var object in unitSizeModels) {
                  //     String unitSize = unitSizeModels[index].unit;
                  //     int qTY = amounts[index];

                  //     print(
                  //         'productID = $productID, memberID=$memberID, unitSize=$unitSize, QTY=$qTY');
                  //     if (qTY != 0) {
                  //       addCart(productID, unitSize, qTY, memberID);
                  //     }
                  //     index++;
                  //   }
                  // }

                  if (qtyS != 0 && qtyS != '') {
                    String unitSize = 's';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=s, QTY=$qtyS');
                    addCart(productID, unitSize, qtyS, memberID);
                  }
                  if (qtyM != 0 && qtyM != '') {
                    String unitSize = 'm';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=m, QTY=$qtyM');
                    addCart(productID, unitSize, qtyM, memberID);
                  }
                  if (qtyL != 0 && qtyL != '') {
                    String unitSize = 'l';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=l, QTY=$qtyL');
                    addCart(productID, unitSize, qtyL, memberID);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> addCart(
      String productID, String unitSize, var qTY, String memberID) async {
    String url =
        'http://www.somsakpharma.com/api/json_savemycart.php?productID=$productID&unitSize=$unitSize&QTY=$qTY&memberId=$memberID';

    http.Response response = await http.get(Uri.parse(url)).then((response) {
      print('upload ok');
      // MaterialPageRoute materialPageRoute = MaterialPageRoute(builder: (BuildContext buildContext){return DetailCart(userModel: myUserModel,);});
      Navigator.pop(context, true);
    });
  }

  Widget showDetailList() {
    return Card(
      child: Stack(
        children: <Widget>[
          showController(),
          addButton(),
        ],
      ),
    );
  }

  ListView showController() {
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        showImage(),
        MyStyle().mySizebox(),
        showTitle(),
        MyStyle().mySizebox(),
        showDetail(),
        showPrice(),
        MyStyle().mySizebox(),
        headTitle('สินค้าที่เกี่ยวข้อง', Icons.thumb_up),
        relate(),
      ],
    );
  }
}
