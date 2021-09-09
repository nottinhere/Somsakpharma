import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;
import 'package:somsakpharma/models/product_all_model.dart';
import 'package:somsakpharma/models/user_model.dart';
import 'package:somsakpharma/utility/my_style.dart';
import 'package:somsakpharma/utility/normal_dialog.dart';
import 'detail.dart';
import 'detail_cart.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:flutter/cupertino.dart';

class ListProduct extends StatefulWidget {
  final int index;
  final UserModel userModel;
  ListProduct({Key key, this.index, this.userModel}) : super(key: key);

  @override
  _ListProductState createState() => _ListProductState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int milliseconds;
  VoidCallback action;
  Timer timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), action);
  }
}

class _ListProductState extends State<ListProduct> {
  // Explicit
  int myIndex;
  List<ProductAllModel> productAllModels = List(); // set array
  List<ProductAllModel> filterProductAllModels = List();
  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';
  String qrString;
  int amountListView = 6, page = 1;
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 500); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;
  bool visible = true;
  // Method
  @override
  void initState() {
    // auto load
    super.initState();
    myIndex = widget.index;
    myUserModel = widget.userModel;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readData(); // read  ข้อมูลมาแสดง
      readCart();
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page++;
          readData();
          print('in the end');
        }
      } else {
        setState(() {
          visible = false;
        });
      }
    });
  }

/************************************** */
  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://somsakpharma.com/api/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];

    for (var map in cartList) {
      setState(() {
        amontCart++;
      });
    }
    print('TotalItemInCart (read)>>$amontCart');
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

  Future<void> readData() async {
    print('Here is readdata function');
    setState(() {
      visible = true;
    });
    String url =
        'http://somsakpharma.com/api/json_product.php?searchKey=$searchString&page=$page';
    if (myIndex != 0) {
      url = '${MyStyle().readProductWhereMode}$myIndex';
    }

    http.Response response = await http.get(url);
    // print('url readData ##################+++++++++++>>> $url');
    var result = json.decode(response.body);
    // print('result = $result');
    // print('url ListProduct ====>>>> $url');
    // print('result ListProduct ========>>>>> $result');

    var itemProducts = result['itemsProduct'];
    int i = 0;
    int len = (filterProductAllModels.length);

    for (var map in itemProducts) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);

      setState(() {
        productAllModels.add(productAllModel);
        filterProductAllModels = productAllModels;
        print(
            ' >> ${len} =>($i)  ${productAllModel.id}  || ${productAllModel.title} (${productAllModel.id})');
      });
      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 50,
          child: Text(
            filterProductAllModels[index].title,
            style: MyStyle().h3bStyle,
          ),
        ),
      ],
    );
  }

  Widget showStock(int index) {
    if (filterProductAllModels[index].stock == 0) {
      return Row(
        children: <Widget>[
          Text(
            'Stock : ',
            style: MyStyle().h3Style,
          ),
          Text(
            '${filterProductAllModels[index].stock.toString()}',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 16.00),
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Text(
            'Stock : ',
            style: MyStyle().h3Style,
          ),
          Text(
            '${filterProductAllModels[index].stock.toString()}',
            style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.normal,
                fontSize: 16.00),
          ),
        ],
      );
    }

    // return Text('na');
  }

  Widget showPrice(int index) {
    return Row(
      children: <Widget>[
        Text(
          'ราคา : ${filterProductAllModels[index].itemprice.toString()}/${filterProductAllModels[index].itemunit.toString()}',
          style: MyStyle().h3Style,
        ),
      ],
    );
    // return Text('na');
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 3.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.63,
      child: Container(
        padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showName(index),
            showStock(index),
            showPrice(index)
          ],
        ),
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: MediaQuery.of(context).size.width * 0.33,
      child: Image.network(filterProductAllModels[index].photo),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Colors.blueGrey.shade100,
          width: 1.0,
        ),
        // bottom: BorderSide(
        //   color: Colors.blueGrey.shade100,
        //   width: 1.0,
        // ),
      ),
    );
  }

  Widget loading() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Loading(indicator: BallPulseIndicator(), size: 10.0),
    );
  }

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Center(child: CupertinoActivityIndicator()),
    );
  }

  Widget showProductItem() {
    int perpage = 10;
    bool loadingIcon = false;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productAllModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          if ((index + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
            // return CupertinoActivityIndicator();
            return myCircularProgress();
          }
          return GestureDetector(
            child: Card(
              child: Container(
                decoration: myBoxDecoration(),
                padding: EdgeInsets.only(top: 0.5),
                child: Row(
                  children: <Widget>[
                    showImage(index),
                    showText(index),
                  ],
                ),
              ),
            ),
            onTap: () {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return Detail(
                  productAllModel: filterProductAllModels[index],
                  userModel: myUserModel,
                );
              });
              Navigator.of(context)
                  .push(materialPageRoute)
                  .then((value) => readCart());
            },
          );
        },
      ),
    );
  }

  Widget showContent() {
    // readCart();
    print('searchString (show content) ===>>> $searchString');
    print('TotalItemInCart (content)>>$amontCart');

    bool searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    return filterProductAllModels.length == 0
        ? showProgressIndicate(searchKey)
        : showProductItem();
  }

  Widget showProgressIndicate(searchKey) {
    print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterProductAllModels.length == 0) {
        //print('aaaaa');
        return Center(child: Text('')); // Search not found

      } else {
        //print('bbbb');
        return Center(child: Text(''));
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }
    /*
    return Center(
      child:
          statusStart ? CircularProgressIndicator() : Text('Search not found'),
    );
    */
  }

  /*
  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }
  */

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        // trailing: IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //       // print('searchString ===>>> $searchString');
        //       setState(() {
        //         page = 1;
        //         productAllModels.clear();
        //         readData();
        //       });
        //     }),
        title: TextField(
          textAlign: TextAlign.center,
          scrollPadding: EdgeInsets.all(5.00),
          style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w300,
              fontSize: 18.00),
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'ค้นหาสินค้า'),
          onChanged: (String string) {
            searchString = string.trim();
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              page = 1;
              productAllModels.clear();
              readData();
            });
          },
        ),
      ),
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
          Navigator.of(context).push(route).then((value) => readCart());
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().textColor,
        title: Text('รายการสินค้า'),
        actions: <Widget>[
          showCart(),
        ],
      ),
      // body: filterProductAllModels.length == 0
      //     ? showProgressIndicate()
      //     : myLayout(),

      body: Column(
        children: <Widget>[
          searchForm(),
          showContent(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          readQRcode();
        },
        icon: Icon(Icons.camera_alt),
        label: Text('Scan'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
