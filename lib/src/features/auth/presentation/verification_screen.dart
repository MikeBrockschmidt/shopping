import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping/src/data/auth_repository.dart';

class VerificationScreen extends StatefulWidget {
  final AuthRepository auth;
  const VerificationScreen(this.auth, {super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late Timer _timer;
  bool _canResendEmail = true;
  int _resendCooldown = 60;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail) return;
    setState(() {
      _canResendEmail = false;
    });
    try {
      await widget.auth.sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifizierungs-E-Mail gesendet!')),
        );
      }
      Timer(_resendCooldown.seconds, () {
        if (mounted) {
          setState(() {
            _canResendEmail = true;
          });
        }
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden der E-Mail: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Mail Verifizierung')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              Text(
                "Bitte checke dein Postfach, um deine E-Mail zu bestätigen.",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Ein Bestätigungslink wurde an ${widget.auth.getCurrentUser()?.email ?? 'deine E-Mail-Adresse'} gesendet.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canResendEmail ? _sendVerificationEmail : null,
                child: Text(
                  _canResendEmail
                      ? 'E-Mail erneut senden'
                      : 'Bitte warte $_resendCooldown Sekunden...',
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await widget.auth.signOut();
                },
                child: const Text('Abmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on int {
  Duration get seconds => Duration(seconds: this);
}
