import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'package:somsakpharma/models/product_all_model.dart';
import 'package:somsakpharma/models/user_model.dart';
import 'package:somsakpharma/utility/my_style.dart';
import 'package:somsakpharma/utility/normal_dialog.dart';
import 'package:somsakpharma/scaffold/my_service.dart';

import 'detail.dart';
import 'detail_cart.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
  var qrString;
  int amountListView = 6, page = 1;
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 500); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;
  bool visible = true;
  int currentIndex;

  var _controller = TextEditingController();

  // Method
  @override
  void initState() {
    // auto load
    super.initState();
    myIndex = widget.index; //widget.index == 0 ? 1 : widget.index;
    myUserModel = widget.userModel;

    if (myIndex == 0) {
      currentIndex = 1;
    } else if (myIndex == 1) {
      currentIndex = 2;
    } else if (myIndex == 2) {
      currentIndex = 3;
    } else if (myIndex == 3) {
      currentIndex = 4;
    } else if (myIndex == 4) {
      currentIndex = 5;
    } else if (myIndex == 5) {
      currentIndex = 6;
    } else if (myIndex == 6) {
      currentIndex = 7;
    }

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

/*************************** */
  String _scanBarcode = 'Unknown';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);

      String url =
          'http://somsakpharma.com/api/json_product.php?bqcode=$barcodeScanRes';

      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('result ===*******>>>> $result');

      int status = result['status'];
      print('status ===>>> $status');
      if (status == 0) {
        normalDialog(
            context, 'Not found', 'ไม่พบ code :: $barcodeScanRes ในระบบ');
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

          // Navigator.of(context).push(route).then((value) {
          //   setState(() {
          //     // readCart();
          //   });
          // });
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

/*************************** */

/************************************** */
  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://somsakpharma.com/api/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];

    for (var map in cartList) {
      setState(() {
        amontCart++;
      });
    }
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
    String memberID = myUserModel.id.toString();

    print('Here is readdata function  ($myIndex)');
    setState(() {
      visible = true;
    });
    String url =
        'http://somsakpharma.com/api/json_product.php?memberId=$memberID&searchKey=$searchString&page=$page';
    if (myIndex == 1) {
      //  สินค้าของคุณ
      url =
          'http://somsakpharma.com/api/json_product_youritem.php?memberId=$memberID&searchKey=$searchString&page=$page';
    } else if (myIndex == 2) {
      //  สินค้าขายดี
      url =
          'http://somsakpharma.com/api/json_product_bestseller.php?memberId=$memberID&searchKey=$searchString&page=$page';
    } else if (myIndex == 3) {
      //  สินค้าแนะนำ
      url =
          'http://somsakpharma.com/api/json_product.php?memberId=$memberID&searchKey=$searchString&page=$page';
    } else if (myIndex == 4) {
      //  สินค้าใหม่
      url =
          'http://somsakpharma.com/api/json_product.php?memberId=$memberID&product_mode=new&searchKey=$searchString&page=$page';
    } else if (myIndex == 5) {
      //
      url =
          'http://somsakpharma.com/api/json_product.php?memberId=$memberID&searchKey=$searchString&page=$page';
    }

    http.Response response = await http.get(Uri.parse(url));
    print('url ($myIndex) readData ##################+++++++++++>>> $url');
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
            style: MyStyle().h4Style,
          ),
          Text(
            '${filterProductAllModels[index].stock.toString()}',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
                fontSize: 13.00),
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Text(
            'Stock : ',
            style: MyStyle().h4Style,
          ),
          Text(
            '${filterProductAllModels[index].stock.toString()}',
            style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.normal,
                fontSize: 13.00),
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
          style: MyStyle().h3bStyle,
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
    int perpage = 20;
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
              return Column(
                children: [
                  GestureDetector(
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
                      MaterialPageRoute materialPageRoute = MaterialPageRoute(
                          builder: (BuildContext buildContext) {
                        return Detail(
                          productAllModel: filterProductAllModels[index],
                          userModel: myUserModel,
                        );
                      });
                      Navigator.of(context)
                          .push(materialPageRoute)
                          .then((value) => readCart());
                    },
                  ),
                  myCircularProgress(),
                  // LinearProgressIndicator(),
                ],
              );
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
          }),
    );
  }

  Widget showContent() {
    bool searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    return filterProductAllModels.length == 0
        ? showProgressIndicate(searchKey)
        : showProductItem();
  }

  Widget showProgressIndicate(searchKey) {
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
  }

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        // trailing: IconButton(
        //     icon: Icon(Icons.search),
        //     onPressed: () {
        //       setState(() {
        //         page = 1;
        //         productAllModels.clear();
        //         readData();
        //       });
        //     }),
        title: TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          scrollPadding: EdgeInsets.all(5.00),
          style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w300,
              fontSize: 18.00),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'ค้นหาสินค้า',
            suffixIcon: IconButton(
              onPressed: () => _controller.clear(),
              icon: Icon(Icons.clear),
            ),
          ),
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

  // Future<void> readQRcode() async {
  //   try {
  //     qrString = await BarcodeScanner.scan();
  //     print('QR code = $qrString');
  //     if (qrString != null) {
  //       decodeQRcode(qrString);
  //     }
  //   } catch (e) {
  //     print('e = $e');
  //   }
  // }

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

  Future<void> readQRcodePreview() async {
    try {
      final qrScanString = await Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => ScanPreviewPage()));

      // final qrScanString = await BarcodeScanner.scan();
      qrString = qrScanString;
      if (qrString != null) {
        decodeQRcode(qrString);
      }
      // setState(() => scanResult = qrScanString);
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

  BottomNavigationBarItem homeBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    );
  }

  BottomNavigationBarItem productBotton(int index) {
    return BottomNavigationBarItem(
      icon: Icon(Icons.medical_services),
      label: 'Product',
    );
  }

  BottomNavigationBarItem youritemBotton(int index) {
    return BottomNavigationBarItem(
      icon: Icon(Icons.check_box_outlined),
      label: 'Your item',
    );
  }

  BottomNavigationBarItem bestsellerBotton(int index) {
    return BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: 'Best Seller',
    );
  }

  BottomNavigationBarItem recommendBotton(int index) {
    return BottomNavigationBarItem(
      icon: Icon(Icons.thumb_up),
      label: 'Recommend',
    );
  }

  BottomNavigationBarItem newproductBotton(int index) {
    return BottomNavigationBarItem(
      icon: Icon(Icons.fiber_new),
      label: 'New Product',
    );
  }

  BottomNavigationBarItem readQrBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt),
      label: 'Barcode Scan',
    );
  }

  Widget showBottomBarNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex, // myIndex,
      items: <BottomNavigationBarItem>[
        homeBotton(),
        productBotton(1),
        // (myIndex == 0 || myIndex == 1 || myIndex == 2)
        youritemBotton(2),
        bestsellerBotton(3),
        recommendBotton(4),
        newproductBotton(5),
      ],
      onTap: (int index) {
        print('index =$index');
        if (index == 0) {
          // routeToDetailCart();
          MaterialPageRoute route = MaterialPageRoute(
            builder: (value) => MyService(
              userModel: myUserModel,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
        } else if (index == 1) {
          routeToListProduct(0);
        } else if (index == 2) {
          routeToListProduct(1);
        } else if (index == 3) {
          routeToListProduct(2);
        } else if (index == 4) {
          routeToListProduct(3);
        } else if (index == 5) {
          routeToListProduct(4);
        }
      },
    );
  }

  Future<void> decodeQRcode(String code) async {
    try {
      String url = 'http://somsakpharma.com/api/json_product.php?bqcode=$code';
      print('urlscan >> $url');

      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);

      int status = result['status'];
      if (status == 0) {
        normalDialog(context, 'No Code', 'No $code in my Database');
      } else {
        var itemProducts = result['itemsProduct'];
        for (var map in itemProducts) {
          ProductAllModel productAllModel = ProductAllModel.fromJson(map);
          MaterialPageRoute route = MaterialPageRoute(
            builder: (BuildContext context) => Detail(
              userModel: myUserModel,
              productAllModel: productAllModel,
            ),
          );
          // Navigator.of(context).push(route).then((value) {
          //   setState(() {
          //     readCart();
          //   });
          // });
          Navigator.of(context).push(route).then((value) => readCart());
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    String txtheader = '';
    if (myIndex != 0) {
      if (myIndex == 1) {
        txtheader = 'สินค้าของคุณ';
      } else if (myIndex == 2) {
        txtheader = 'สินค้าขายดี';
      } else if (myIndex == 3) {
        txtheader = 'สินค้าแนะนำ';
      } else if (myIndex == 4) {
        txtheader = 'สินค้าใหม่';
      }
    } else {
      txtheader = 'รายการสินค้า';
    }
    return Scaffold(
      bottomNavigationBar: showBottomBarNav(),
      appBar: AppBar(
        backgroundColor: MyStyle().textColor,
        title: Text(txtheader),
        actions: <Widget>[
          showCart(),
        ],
      ),
      body: Column(
        children: <Widget>[
          searchForm(),
          showContent(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // readQRcode();
          // readQRcodePreview();
          scanBarcodeNormal();
        },
        icon: Icon(Icons.camera_alt),
        label: Text('Scan'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class ScanPreviewPage extends StatefulWidget {
  @override
  _ScanPreviewPageState createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Somsak Pharma'),
          backgroundColor: MyStyle().textColor,
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ScanPreviewWidget(
            onScanResult: (result) {
              debugPrint('scan result: $result');
              Navigator.pop(context, result);
            },
          ),
        ),
      ),
    );
  }
}
