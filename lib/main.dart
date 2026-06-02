import 'package:flutter/material.dart';
import 'features/onboarding/onboarding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlogyanPrepApp());
}

class AlogyanPrepApp extends StatelessWidget {
  const AlogyanPrepApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alogyan Prep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF0A0A14),
      ),
      // TODO: Replace with a proper router (go_router) when more screens exist.
      // For now, always start with onboarding.
      home: OnboardingScreen(
        onCompleted: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const _HomeStub(),
            ),
          );
        },
      ),
    );
  }
}
class _HomeStub extends StatelessWidget {
  const _HomeStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0A14),
      body: Center(
        child: Text(
          '🏠 Home Screen\n(ALO-002 coming next)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}