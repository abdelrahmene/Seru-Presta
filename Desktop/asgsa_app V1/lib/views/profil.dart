import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();

  ProfilePage(ValueKey<String> valueKey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        centerTitle: true,
      ),
      body: user != null ? _buildProfileView(context) : _buildNotLoggedInView(context),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    return Center(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user!.photoURL ?? "https://via.placeholder.com/150"),
              ),
              SizedBox(height: 10),
              Text(
                user!.displayName ?? "Utilisateur inconnu",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                user!.email ?? "Email non disponible",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Divider(),
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text("Nom"),
                subtitle: Text(user!.displayName ?? "Inconnu"),
              ),
              ListTile(
                leading: Icon(Icons.email, color: Colors.red),
                title: Text("Email"),
                subtitle: Text(user!.email ?? "Non disponible"),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text("Déconnexion"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.pushReplacementNamed(context, "/login");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Vous n'êtes pas connecté",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text("Se connecter"),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }
}
