import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final List<WishlistItem> _wishlistItems = [];
  final TextEditingController _controller = TextEditingController();
  int? _editingIndex; // Menyimpan indeks item yang sedang diedit

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('wishlist').get();
    setState(() {
      _wishlistItems.clear();
      for (var doc in snapshot.docs) {
        _wishlistItems.add(WishlistItem.fromJson(doc.data()));
      }
    });
  }

  Future<void> _saveWishlist() async {
    for (var item in _wishlistItems) {
      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc(item.title) // Gunakan title sebagai id dokumen
          .set(item.toJson());
    }
  }

  void _resetInput() {
    _controller.clear();
    _editingIndex = null; // Reset indeks setelah update
  }

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        if (_editingIndex == null) {
          // Tambah item baru
          _wishlistItems.add(WishlistItem(
            title: _controller.text,
            isPurchased: false,
          ));
        } else {
          // Update item yang sudah ada
          WishlistItem updatedItem = WishlistItem(
            title: _controller.text,
            isPurchased: _wishlistItems[_editingIndex!].isPurchased,
          );

          // Hapus item lama dari Firestore
          FirebaseFirestore.instance
              .collection('wishlist')
              .doc(_wishlistItems[_editingIndex!]
                  .title) // Menggunakan title item lama
              .delete();

          // Update item di daftar lokal
          _wishlistItems[_editingIndex!] = updatedItem;

          // Tambahkan item yang sudah diperbarui ke Firestore
          FirebaseFirestore.instance
              .collection('wishlist')
              .doc(updatedItem.title) // Menggunakan title item yang baru
              .set(updatedItem.toJson());
        }
        _resetInput(); // Reset input field
      });

      // Panggil _saveWishlist hanya jika menambah item baru
      if (_editingIndex == null) {
        _saveWishlist();
      }
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
        FirebaseFirestore.instance
            .collection('wishlist')
            .doc(_wishlistItems[index].title) // Hapus dari Firestore
            .delete();
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

  void _editItem(int index) {
    setState(() {
      _controller.text = _wishlistItems[index].title;
      _editingIndex = index; // Set indeks untuk edit
    });
  }

  void _shareWishlist() {
    final String items = _wishlistItems.map((item) => item.title).join(', ');
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
          ElevatedButton(
            onPressed: _addItem,
            child: Text(
              _editingIndex == null ? 'Add to Wishlist' : 'Update Item',
              style: TextStyle(color: Colors.white),
            ),
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
                        icon: Icon(Icons.edit),
                        onPressed: () => _editItem(index),
                        color: Colors.blue,
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
  bool isPurchased;

  WishlistItem({
    required this.title,
    this.isPurchased = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isPurchased': isPurchased,
    };
  }

  static WishlistItem fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      title: json['title'],
      isPurchased: json['isPurchased'],
    );
  }
}
