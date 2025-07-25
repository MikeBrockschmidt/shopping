import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;

  const SocialLoginButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        height: 40,
        child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(icon)),
      ),
    );
  }
}
