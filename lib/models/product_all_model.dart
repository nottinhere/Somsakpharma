class ProductAllModel {
  String title;
  String productCode;
  String photo;
  String itemprice;
  String itemunit;
  String priceList;
  String detail;
  int stock;
  int id;

  ProductAllModel(
      {this.title,
      this.productCode,
      this.photo,
      this.itemprice,
      this.itemunit,
      this.priceList,
      this.detail,
      this.stock,
      this.id});

  ProductAllModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    productCode = json['product_code'];
    photo = json['photo'];
    itemprice = json['itemprice'];
    itemunit = json['itemunit'];
    priceList = json['price_list'];
    detail = json['detail'];
    stock = json['stock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['product_code'] = this.productCode;
    data['photo'] = this.photo;
    data['itemprice'] = this.itemprice;
    data['itemunit'] = this.itemunit;
    data['price_list'] = this.priceList;
    data['detail'] = this.detail;
    data['stock'] = this.stock;
    data['id'] = this.id;
    return data;
  }
}

