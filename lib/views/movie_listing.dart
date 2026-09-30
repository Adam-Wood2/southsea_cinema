
import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';

class MovieListing extends StatefulWidget{
  const MovieListing({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MovieListingState();
  }
}


class _MovieListingState extends State<MovieListing> {
  int _quantity = 0;
  int _cartQuantity = 0;
  double _price = 5.99;
  double _totalPrice = 0.0;
  bool _itemInCart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle, style: cinemaHeaderStyle),
        backgroundColor: cinemaSurface,
        iconTheme: const IconThemeData(color: cinemaBrand),
        elevation: 0,
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          spacing: 20,
          children: [
            Text(
              "Everything Everywhere All At Once (2022) (15)",
              style: listingTitleStyle,
            ),
            SizedBox(height: 5,),
            Text(
              "Southsea Cinema Room",
              style: listingDescriptionStyle,
            ),
            Text(
              "Thursday 22 Oct 2026, 18:00 - Ends at 20:19",
              style: listingDescriptionStyle
            ),
            SizedBox(height: 5,),
            Text("Summary:", style: listingDescriptionStyle,),
            Text("A middle-aged Chinese immigrant is swept up into an insane adventure in which she alone can save existence by exploring other universes and connecting with the lives she could have led."),
            SizedBox(height: 5,),
            Text(
              "Please note that Discount / Membership Benefits will be applied once you have selected your tickets.",
              style: listingDescriptionStyle,
            ),
            Text(
              "Select Quantities (Up to 5 in total)",
              style: listingDescriptionStyle,
            ),
            Row(
              children: [
                DropdownMenu(
                  initialSelection: 0,
                  selectOnly: true,
                  onSelected: (int? value) {
                    if (value != null) {
                      setState(() {
                        _quantity = value;
                        //print(_quantity);
                      });
                    }
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: 0, label: "0"),
                    DropdownMenuEntry(value: 1, label: "1"),
                    DropdownMenuEntry(value: 2, label: "2"),
                    DropdownMenuEntry(value: 3, label: "3"),
                    DropdownMenuEntry(value: 4, label: "4"),
                    DropdownMenuEntry(value: 5, label: "5"),
                  ]
                ),
                SizedBox(width: 15,),
                ElevatedButton(onPressed: _addToBasket, child: Text("Add to order"))
              ],
            ),
            _itemInCart ? Text("$_cartQuantity tickets added to basket (£$_totalPrice)") : Text("")
          ]
        ),
      ),
      )
    );
  }

  void _addToBasket() {
    _totalPrice = _quantity*_price;
    _cartQuantity = _quantity;
    setState(() {
      _itemInCart = true;
    });
  }
}


