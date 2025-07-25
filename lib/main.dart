import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping/src/theme/app_theme.dart';
import 'package:shopping/firebase_options.dart';
import 'package:shopping/src/data/auth_repository.dart';
import 'package:shopping/src/data/database_repository.dart';
import 'package:shopping/src/features/auth/presentation/login_screen.dart';
import 'package:shopping/src/features/group/presentation/group_selection_screen.dart';
import 'package:shopping/src/features/auth/presentation/verification_screen.dart';
import 'package:shopping/src/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<DatabaseRepository>(create: (_) => DatabaseRepository()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Shopping',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) {
          return StreamBuilder<User?>(
            stream: authRepository.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final user = snapshot.data;
                if (user == null) {
                  return LoginScreen(authRepository);
                } else {
                  if (!user.emailVerified) {
                    return VerificationScreen(authRepository);
                  } else {
                    return GroupSelectionScreen(
                      authRepository,
                      context.read<DatabaseRepository>(),
                    );
                  }
                }
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),
    );
  }
}
