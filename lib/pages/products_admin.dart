import 'package:flutter/material.dart';
import 'package:flutter_app2/scoped-models/main.dart';
import '../ui_elements/logout_list_tile.dart';
import './product_edit.dart';
import './product_list.dart';

class ProductsAdminPage extends StatelessWidget{
final MainModel model;
ProductsAdminPage(this.model);
  Widget _buildSideDrawer(BuildContext context)
  {
    return  Drawer(child: Column(children: <Widget>[
      AppBar(automaticallyImplyLeading:false,title: Text('Select an item'),),
      ListTile(
        leading: Icon(Icons.shop),
        title: Text('All Products'),onTap: (){
        Navigator.pushReplacementNamed(context, '/');
      },),
      Divider(),
      LogoutListTile(),
    ],),);
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length:2,child:Scaffold(
        drawer:_buildSideDrawer(context),
        appBar: AppBar(
          title: Text('MyApp'),
          bottom: TabBar(tabs: <Widget>[
            Tab(icon:Icon(Icons.create),text: 'Create Product',),
            Tab(icon:Icon(Icons.list),text: 'My Product',)
          ],
          ),
        ),
        body:TabBarView(children: <Widget>[
          ProductEditPage(),
          ProductListPage(model),
        ],
        ),
      ),
    );
  }
}
