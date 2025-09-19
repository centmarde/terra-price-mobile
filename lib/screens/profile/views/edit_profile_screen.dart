import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _emailError;
  String? _fullNameError;
  String? _oldPasswordError;
  String? _passwordError;
  String? _confirmPasswordError;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (!mounted) return;
      _emailController.text = user.email ?? '';
      // Fetch full_name from public.profiles
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();
      if (!mounted) return;
      if (response['full_name'] != null) {
        _fullNameController.text = response['full_name'] as String;
      }
    }
  }

  Future<void> _updateProfile() async {
    // Reset field errors
    setState(() {
      _emailError = null;
      _fullNameError = null;
      _oldPasswordError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool hasError = false;
    if (_fullNameController.text.isEmpty) {
      setState(() => _fullNameError = 'Enter your full name');
      hasError = true;
    }
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Enter your email');
      hasError = true;
    }
    if (_passwordController.text.isNotEmpty &&
        _oldPasswordController.text.isEmpty) {
      setState(
        () => _oldPasswordError = 'Enter your old password to change password',
      );
      hasError = true;
    }
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      hasError = true;
    }
    if (hasError) {
      // Force form to revalidate so errors show below fields
      _formKey.currentState?.validate();
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final password = _passwordController.text.trim();
    String? error;

    // ...existing code...

    try {
      // If password is being changed, check old password by sign-in
      if (password.isNotEmpty) {
        final emailToCheck = email.isNotEmpty ? email : user?.email;
        final signInRes = await Supabase.instance.client.auth
            .signInWithPassword(email: emailToCheck, password: oldPassword);
        if (signInRes.user == null) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _oldPasswordError = 'Old password is incorrect';
          });
          // Force form to revalidate so error shows below field
          _formKey.currentState?.validate();
          return;
        }
      }

      // Update email and/or password in auth.users
      if (email != user?.email || password.isNotEmpty) {
        final res = await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            email: email != user?.email ? email : null,
            password: password.isNotEmpty ? password : null,
          ),
        );
        if (res.user == null) {
          error = 'Failed to update email or password.';
        }
      }

      // Update full_name in public.profiles
      if (user != null && fullName.isNotEmpty) {
        await Supabase.instance.client
            .from('profiles')
            .update({'full_name': fullName})
            .eq('id', user.id);
      }
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _passwordController.clear();
      _oldPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _fullNameError,
              ),
              if (_fullNameError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    _fullNameError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _emailError,
              ),
              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    _emailError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(labelText: 'Old Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _oldPasswordError,
              ),
              if (_oldPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    _oldPasswordError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _passwordError,
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    _passwordError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (_) => _confirmPasswordError,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
