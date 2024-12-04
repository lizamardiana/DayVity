import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final List<WishlistItem> _wishlistItems = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistData = prefs.getString('wishlist');
    if (wishlistData != null) {
      final List decodedData = jsonDecode(wishlistData);
      setState(() {
        _wishlistItems.addAll(decodedData.map((e) => WishlistItem.fromJson(e)));
      });
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(_wishlistItems.map((e) => e.toJson()).toList());
    await prefs.setString('wishlist', encodedData);
  }

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _wishlistItems.add(WishlistItem(
          title: _controller.text,
          note: _noteController.text,
          category: _categoryController.text,
          isPurchased: false,
        ));
        _controller.clear();
        _noteController.clear();
        _categoryController.clear();
      });
      _saveWishlist();
    }
  }

  void _removeItem(int index) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm) {
      setState(() {
        _wishlistItems.removeAt(index);
      });
      _saveWishlist();
    }
  }

  void _togglePurchased(int index) {
    setState(() {
      _wishlistItems[index].isPurchased = !_wishlistItems[index].isPurchased;
    });
    _saveWishlist();
  }

  void _shareWishlist() {
    final String items = _wishlistItems
        .map((item) => '${item.title} (${item.category})')
        .join(', ');
    final String message = "My Wishlist: $items";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sharing: $message")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
        backgroundColor: Colors.pink.shade600,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareWishlist,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Add New Item',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: Text('Add to Wishlist',
                style: TextStyle(
                    color: Colors.white)), // Text color changed to white
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade600,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _wishlistItems[index].title,
                    style: TextStyle(
                      decoration: _wishlistItems[index].isPurchased
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_wishlistItems[index].note.isNotEmpty)
                        Text('Note: ${_wishlistItems[index].note}'),
                      if (_wishlistItems[index].category.isNotEmpty)
                        Text('Category: ${_wishlistItems[index].category}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _wishlistItems[index].isPurchased
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        onPressed: () => _togglePurchased(index),
                        color: Colors.green,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _removeItem(index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WishlistItem {
  String title;
  String note;
  String category;
  bool isPurchased;

  WishlistItem({
    required this.title,
    this.note = '',
    this.category = '',
    this.isPurchased = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'note': note,
      'category': category,
      'isPurchased': isPurchased,
    };
  }

  static WishlistItem fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      title: json['title'],
      note: json['note'],
      category: json['category'],
      isPurchased: json['isPurchased'],
    );
  }
}
