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
        title: Text('Hapus Item'),
        content: Text('Apakah Anda yakin ingin menghapus item ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text('Hapus'),
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
    final String message = "Wishlist saya: $items";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Berbagi: $message")),
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
                labelText: 'Tambahkan Item Baru',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Kategori (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: Text('Tambahkan ke Wishlist'),
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
                        Text('Catatan: ${_wishlistItems[index].note}'),
                      if (_wishlistItems[index].category.isNotEmpty)
                        Text('Kategori: ${_wishlistItems[index].category}'),
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
