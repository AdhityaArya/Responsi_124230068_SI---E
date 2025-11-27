// lib/screens/register.dart

import 'package:flutter/material.dart';
import '../services/authentication.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthPreferenceHelper _authHelper = AuthPreferenceHelper();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final isSuccess = await _authHelper.register(username, password);

    setState(() => _isLoading = false);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pendaftaran Berhasil! Silakan Login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Kembali ke halaman Login
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pendaftaran Gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // Input Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_add),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_open),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Register
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
