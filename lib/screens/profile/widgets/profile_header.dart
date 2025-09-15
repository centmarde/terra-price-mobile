// lib/screens/profile/widgets/profile_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AuthProvider to fetch email from Supabase
class AuthProvider with ChangeNotifier {
  String _email = '';
  String _fullName = '';
  String get email => _email;
  String get fullName => _fullName;

  Future<void> fetchUserDataFromSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _email = user.email ?? '';
      // Fetch full_name from public.profiles
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();
      if (response['full_name'] != null) {
        _fullName = response['full_name'] as String;
      } else {
        _fullName = '';
      }
      notifyListeners();
    }
  }
}

// ProfileHeader widget
class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when header is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchUserDataFromSupabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final email = authProvider.email;
        final fullName = authProvider.fullName;

        return Container(
          padding: const EdgeInsets.all(16),
          // Removed color: Colors.blue
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : 'Loading...',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 27, 27, 27),
                      ),
                    ),
                    Text(
                      email.isNotEmpty ? email : 'Loading...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(179, 29, 29, 29),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
