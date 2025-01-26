import 'package:flutter/material.dart';
import 'db_handler.dart';

class LocalUserScreen extends StatefulWidget {
  @override
  _LocalUserScreenState createState() => _LocalUserScreenState();
}

class _LocalUserScreenState extends State<LocalUserScreen> {
  final DBHandler _dbHandler = DBHandler();

  late Future<List<Map<String, dynamic>>> _favorites;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favorites = _dbHandler.fetchFavorites();
    });
  }

  void _removeFromFavorites(int id) async {
    await _dbHandler.deleteFavorite(id);
    _loadFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User removed from favorites!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _favorites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: SelectableText('Error: ${snapshot.error}'));
        } else {
          final favorites = snapshot.data!;
          if (favorites.isEmpty) {
            return Center(child: Text('No favorite users yet.'));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final user = favorites[index];
              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeFromFavorites(user['id']),
                ),
              );
            },
          );
        }
      },
    );
  }
}
