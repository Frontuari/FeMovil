import 'package:flutter/material.dart';






class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                backgroundColor: const Color.fromARGB(255, 236, 247, 255),
          
          appBar: AppBar(title: const Text("Productos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color.fromARGB(255, 105, 102, 102),  ),),
                    backgroundColor: const Color.fromARGB(255, 236, 247, 255, ),
                      iconTheme: const IconThemeData(color: Color.fromARGB(255, 105, 102, 102)),

          ),
          body: const Text("Estos son los productos"),
    );
  }
}