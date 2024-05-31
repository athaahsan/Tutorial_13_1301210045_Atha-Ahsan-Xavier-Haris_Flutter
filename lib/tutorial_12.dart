import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Product.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Tutorial12(),
  ));
}

class Tutorial12 extends StatefulWidget {
  @override
  _Tutorial12State createState() => _Tutorial12State();
}

class _Tutorial12State extends State<Tutorial12> {
  late Future<List<Product>> futureProducts;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.100.10:8000/api/products'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((product) => Product.fromJson(product)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> addProduct() async {
    final response = await http.post(
      Uri.parse('http://192.168.100.10:8000/api/products'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': nameController.text,
        'description': descriptionController.text,
        'price': priceController.text,
        'stock': stockController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureProducts = fetchProducts();
      });
    } else {
      throw Exception('Failed to add product');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Center(
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            'Description: ${snapshot.data![index].description}'),
                        Text('Price: Rp. ${snapshot.data![index].price}'),
                        Text('Stock: ${snapshot.data![index].stock}'),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Add Product"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: "Product Name"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(hintText: "Description"),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(hintText: "Price"),
                    ),
                    TextField(
                      controller: stockController,
                      decoration: InputDecoration(hintText: "Stock"),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Save"),
                    onPressed: () {
                      addProduct();
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}