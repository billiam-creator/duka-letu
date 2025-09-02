import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:duka_letu/providers/auth_provider.dart';
import 'package:duka_letu/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      // Check if the user is an admin
      if (authProvider.userRole == 'admin') {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Profile'),
            backgroundColor: Colors.red,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
          body: const Center(
            child: Text(
              'Admin account logged in.',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      } else {
        // Regular user profile view
        final userEmail = authProvider.user?.email ?? 'User';
        final userName = authProvider.user?.displayName ?? userEmail.split('@')[0];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildProfileOption(
                    context,
                    icon: Icons.notifications,
                    title: 'Notification',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildProfileOption(
                    context,
                    icon: Icons.list_alt,
                    title: 'My Order',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildProfileOption(
                    context,
                    icon: Icons.payment,
                    title: 'Payment',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildProfileOption(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Cart',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildProfileOption(
                    context,
                    icon: Icons.favorite,
                    title: 'Wish List',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildProfileOption(
                    context,
                    icon: Icons.lock,
                    title: 'Password',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      // Guest profile view (unchanged)
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_off_outlined,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'You are currently a guest',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text(
                'Log in to access your profile and purchases.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Log In'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}