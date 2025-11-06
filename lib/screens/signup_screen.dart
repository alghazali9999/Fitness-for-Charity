import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../database/database_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  final _usernameC = TextEditingController();

  bool _loading = false;
  bool _fetchingCountryList = true;

  bool _showPass = false;
  bool _showConfirm = false;

  String? _selectedCountry;
  List<String> _countries = [];

  double _passwordStrength = 0.0;
  String _passwordFeedback = "";

  @override
  void initState() {
    super.initState();
    _fetchCountryList();
    _passC.addListener(() {
      _checkPasswordStrength(_passC.text);
    });
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    _usernameC.dispose();
    super.dispose();
  }

  Future<void> _fetchCountryList() async {
    try {
      final uri = Uri.parse('https://restcountries.com/v3.1/all?fields=name');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final names = data
            .map((e) => e['name']?['common'])
            .whereType<String>()
            .toList()
          ..sort();

        if (!mounted) return;
        setState(() {
          _countries = names;
          _fetchingCountryList = false;
          if (names.isNotEmpty) _selectedCountry = names.first;
        });
      } else {
        throw Exception("Invalid response");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchingCountryList = false;
        _countries = ["Indonesia"]; // fallback jika gagal fetch
        _selectedCountry = "Indonesia";
      });
    }
  }

  Future<void> _checkPasswordStrength(String password) async {
    if (password.isEmpty) {
      if (!mounted) return;
      setState(() {
        _passwordStrength = 0;
        _passwordFeedback = "";
      });
      return;
    }

    // cek password breach
    try {
      final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
      final prefix = hash.substring(0, 5);
      final suffix = hash.substring(5);

      final res = await http
          .get(Uri.parse('https://api.pwnedpasswords.com/range/$prefix'))
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final lines = res.body.split('\n');
        final match = lines.firstWhere(
          (line) => line.startsWith(suffix),
          orElse: () => '',
        );

        if (match.isNotEmpty) {
          final count = int.tryParse(match.split(':')[1]) ?? 0;
          if (!mounted) return;
          setState(() {
            _passwordStrength = 0.1;
            _passwordFeedback =
                "⚠️ Password ditemukan dalam $count pelanggaran data!";
          });
          return;
        }
      }
    } catch (_) {}

    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;

    String fb = strength < 0.5
        ? "Weak"
        : strength < 0.75
            ? "Medium"
            : "Strong";

    if (!mounted) return;
    setState(() {
      _passwordStrength = strength;
      _passwordFeedback = fb;
    });
  }

  Future<void> _signup() async {
    final email = _emailC.text.trim();
    final pass = _passC.text;
    final confirm = _confirmC.text;
    final username = _usernameC.text.trim();
    final country = _selectedCountry ?? "";

    if (username.isEmpty) return _showError("Username required");
    if (country.isEmpty) return _showError("Country required");

    if (email.isEmpty ||
        !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return _showError("Invalid email");
    }

    if (pass.isEmpty || confirm.isEmpty) return _showError("Password required");
    if (pass != confirm) return _showError("Passwords do not match");
    if (_passwordStrength < 0.5) return _showError("Password too weak");

    setState(() => _loading = true);

    try {
      final emailExists = await DBHelper.instance.userExists(email);
      if (emailExists) {
        setState(() => _loading = false);
        _showError("Email already registered");
        return;
      }

      final usernameExists = await DBHelper.instance.usernameExists(username);
      if (usernameExists) {
        setState(() => _loading = false);
        _showError("Username already taken");
        return;
      }

      // TODO: Tambahkan pilihan gender di UI dan gunakan nilainya di sini.
      const gender = "male";
      final created = await DBHelper.instance.createUser(
        email,
        pass,
        username,
        country,
        gender,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (created) {
        _showSuccess("Account created successfully!");
        navKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        _showError("Failed to create account");
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError("Unexpected error: ${e.toString()}");
    }
  }

  void _showError(String msg) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showSuccess(String msg) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2D6A4F),
              Color(0xFF40916C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.22),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    size: 55,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Join our fitness community",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInput(_usernameC, "Username", Icons.person),
                      const SizedBox(height: 14),
                      _fetchingCountryList
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField2<String>(
                              value: _selectedCountry,
                              items: _countries
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCountry = v),
                              decoration: _inputBox("Country"),
                            ),
                      const SizedBox(height: 14),
                      _buildInput(
                        _emailC,
                        "Email",
                        Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _buildPassword(
                        controller: _passC,
                        label: "Password",
                        visible: _showPass,
                        onToggle: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: Colors.grey[300],
                        color: _passwordStrength < 0.5
                            ? Colors.red
                            : _passwordStrength < 0.75
                                ? Colors.orange
                                : const Color(0xFF2D6A4F),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _passwordFeedback,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      _buildPassword(
                        controller: _confirmC,
                        label: "Confirm Password",
                        visible: _showConfirm,
                        onToggle: () =>
                            setState(() => _showConfirm = !_showConfirm),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputBox(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFE9F5EC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1B4332)),
        filled: true,
        fillColor: const Color(0xFFE9F5EC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPassword({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF1B4332)),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFF1B4332),
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFE9F5EC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
