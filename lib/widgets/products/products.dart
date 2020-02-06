 import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './product_card.dart';
import '../../models/product.dart';
import '../../scoped-models/main.dart';


class Products extends StatelessWidget{
//  final List<Product> products;
//
//  Products(this.products);
  //Products(this.products,{this.deleteProduct});
    // This is the optional argument
  Widget _buildProductList(List<Product> products){

//    return products.length > 0 ? ListView.builder(
//        itemBuilder:_buildProductItem,
//        itemCount: products.length,
//    ):Center(child: Text('No products added, Please add some.'),);
  Widget productCard;
  if(products.length>0)
    {
      productCard=ListView.builder(
         itemBuilder:(BuildContext context,int index)=>ProductCard(products[index],index),
          itemCount: products.length,
     );
    }
  else
    {
      productCard=Center(child: Text('No products added, Please add some.'),);
    }
  return productCard;
  }

  @override
  Widget build(BuildContext context)
  {
    return ScopedModelDescendant<MainModel>(
      builder:(BuildContext context,Widget child, MainModel model){
          return  _buildProductList(model.displayedProducts);
      },
    );
  }
}