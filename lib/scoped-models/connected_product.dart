import 'dart:convert';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  String _selProductId;
  User _authenticatedUser;
  bool _isLoading = false;

//  Future<bool> addProduct(
//      String title, String description, String imageUrl, double price) {
//    _isLoading = true;
//    notifyListeners();
//    final Map<String, dynamic> productData = {
//      'title': title,
//      'description': description,
//      'imageUrl':
//      'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
//      'price': price,
//      'userEmail': _authenticatedUser.email,
//      'userId': _authenticatedUser.id
//    };
//    return http
//        .post('https://flutter-products-f2453.firebaseio.com/products.json',
//        body: json.encode(productData))
//        .then((http.Response response) {
//          if(response.statusCode!=200 && response.statusCode!=201)
//            {
//              _isLoading=false;
//              notifyListeners();
//              return false;
//            }
//      final Map<String, dynamic> responseData = json.decode(response.body);
//      final Product newProduct = Product(
//          id: responseData['name'],
//          title: title,
//          description: description,
//          imageUrl: imageUrl,
//          price: price,
//          userEmail: _authenticatedUser.email,
//          userId: _authenticatedUser.id);
//      _products.add(newProduct);
//      _isLoading = false;
//      notifyListeners();
//      return true;
//    })
//    .catchError((error){
//      _isLoading=false;
//      notifyListeners();
//      return false;
//    });
//  }


}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

   int get selectedProductIndex{
  return _products.indexWhere((Product product){
  return product.id==_selProductId;
  });
}
  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product product){
      return product.id==_selProductId;
    });
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }
  Future<bool> addProduct(
      String title, String description, String imageUrl, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imageUrl':
      'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id
    };
    try {
      final http.Response response = await http
          .post('https://flutter-products-f2453.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    }catch(error)
    {
      _isLoading=false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      String title, String description, String imageUrl, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'imageUrl':
      'https://upload.wikimedia.org/wikipedia/commons/6/68/Chocolatebrownie.JPG',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId
    };
    return http
        .put(
        'https://flutter-products-f2453.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
        body: json.encode(updateData))
        .then((http.Response response) {
      if(response.statusCode!=200 && response.statusCode!=201)
      {
        _isLoading=false;
        notifyListeners();
        return false;
      }
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);

      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
      return true;
    }) .catchError((error){
      _isLoading=false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    notifyListeners();
    return http
        .delete(
        'https://flutter-products-f2453.firebaseio.com/products/${deletedProductId}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }) .catchError((error){
      _isLoading=false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts({onlyForUser=false}) {
    _isLoading = true;
    notifyListeners();
    return http
        .get('https://flutter-products-f2453.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
          isFavorite: productData['wishlistUsers']==null?false:(productData['wishlistUsers'] as Map<String,dynamic>).containsKey(_authenticatedUser.id),
        );
        fetchedProductList.add(product);
      });
      _products = fetchedProductList.where((Product product){
        return product.userId==_authenticatedUser.id;
      }).toList();
      _products = onlyForUser?fetchedProductList.where((Product product){
        return product.userId==_authenticatedUser.id;
      }).toList():fetchedProductList;
      _isLoading = false;
      notifyListeners();
      //_selProductId=null;
    }) .catchError((error){
      _isLoading=false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavoriteStatus() async{
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        id:selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        imageUrl: selectedProduct.imageUrl,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    notifyListeners();
    http.Response response;
    if(newFavoriteStatus) {
      response = await http.put(
          'https://flutter-products-f2453.firebaseio.com/products/${selectedProduct
              .id}/wishlistUsers/${_authenticatedUser
              .id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    }
    else
      {
          await http.delete('https://flutter-products-f2453.firebaseio.com/products/${selectedProduct
              .id}/wishlistUsers/${_authenticatedUser
              .id}.json?auth=${_authenticatedUser.token}');
      }
    if(response.statusCode!=200 && response.statusCode!=201)
      {
        final Product updatedProduct = Product(
            id:selectedProduct.id,
            title: selectedProduct.title,
            description: selectedProduct.description,
            price: selectedProduct.price,
            imageUrl: selectedProduct.imageUrl,
            userEmail: selectedProduct.userEmail,
            userId: selectedProduct.userId,
            isFavorite: newFavoriteStatus);
        _products[selectedProductIndex] = updatedProduct;
        notifyListeners();
      }


  }

  void selectProduct(String productId) {
    _selProductId = productId;
    notifyListeners();
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {

  Timer _authTimer;
  PublishSubject<bool> _userSubject=PublishSubject();


  User get user{
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject{
      return _userSubject;
  }
  Future <Map<String,dynamic>> authenticate(String email, String password,[AuthMode mode=AuthMode.Login]) async {
    _isLoading=true;
    notifyListeners();
    final Map<String,dynamic> authData={
      'email':email,
      'password':password,
      'returnSecureToken':true,
    };
    http.Response response;
    if(mode==AuthMode.Login)
      {
        response= await http.post('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyAsfa9Vo7Oe20DIeRJouLwxAyJ8R6arMDk',
          body: json.encode(authData),
          headers: {'Content-Type':'application/json'},
        );
      }
    else
      {
        response= await http.post('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAsfa9Vo7Oe20DIeRJouLwxAyJ8R6arMDk',
            body: json.encode(authData),
            headers: {'Content-Type':'application/json'}
        );
      }

    final Map<String,dynamic> responseData=json.decode(response.body);
    bool hasError=true;
    String message='Something went wrong';
    if(responseData.containsKey('idToken'))
    {
      hasError=false;
      message='Authentication Successfull';
      _authenticatedUser=User(
        id: responseData['localId'],
        email: email,
        token: responseData['idToken']
      );
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now=DateTime.now();
      final DateTime expiryTime=now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs=await SharedPreferences.getInstance();
      prefs.setString('token',responseData['idToken'] );
      prefs.setString('userEmail',email);
      prefs.setString('userId',responseData['localId'] );
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    }
    else if(responseData['error']['message']=='EMAIL_EXISTS')
    {
      message='This email already exist';
    }
    else if(responseData['error']['message']=='EMAIL_NOT_FOUND')
    {
      message='This email was not found.';
    }
    else if(responseData['error']['message']=='INVALID_PASSWORD')
    {
      message='This password is invalid.';
    }
    _isLoading=false;
    notifyListeners();
    return{'success':!hasError,'message':message};

  }
  void autoAuthenticate() async{
    final SharedPreferences prefs= await SharedPreferences.getInstance();
    final String token=prefs.getString('token');
    final String expiryTimeString=prefs.getString('expiryTime');
    if(token!=null)
      {
        final DateTime now=DateTime.now();
        final parsedExpiryTime=DateTime.parse(expiryTimeString);
        if(parsedExpiryTime.isBefore(now))
          {
            _authenticatedUser=null;
            notifyListeners();
            return;
          }
        final String userEmail=prefs.getString('userEmail');
        final String userId=prefs.getString('userId');
        final int tokenLifeSpan=parsedExpiryTime.difference(now).inSeconds;
        _authenticatedUser=User(
          id: userId,
          email: userEmail,
          token:token,
        );
        _userSubject.add(true);
        setAuthTimeout(tokenLifeSpan);
        notifyListeners();
      }

  }
  void logout() async
  {
    print('LOGOUT');
    _authenticatedUser=null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs= await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userId');
    prefs.remove('userEmail');
   // _userSubject.add(false);
  }

  void setAuthTimeout(int time) {
    _authTimer=Timer(Duration(seconds: time),logout);

    }


//  Future<Map<String,dynamic>> signup(String email,String password) async
//  {
//    _isLoading=true;
//    notifyListeners();
//    final Map<String,dynamic> authData={
//      'email':email,
//      'password':password,
//      'returnSecureToken':true,
//    };
//   final http.Response response= await http.post('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyAsfa9Vo7Oe20DIeRJouLwxAyJ8R6arMDk',
//          body: json.encode(authData),
//          headers: {'Content-Type':'application/json'}
//   );
//      final Map<String,dynamic> responseData=json.decode(response.body);
//      bool hasError=true;
//      String message='Something went wrong';
//      if(responseData.containsKey('idToken'))
//        {
//          hasError=false;
//          message='Authentication Successfull';
//        }
//      else if(responseData['error']['message']=='EMAIL_EXISTS')
//        {
//          message='This email already exist';
//        }
//      _isLoading=false;
//      notifyListeners();
//      return{'success':!hasError,'message':message};
//  }
}

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
