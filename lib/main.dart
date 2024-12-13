import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:message_in_a_botlle/routes.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  ZegoUIKit().initLog().then((value) => ZegoUIKitPrebuiltCallInvitationService()
      .useSystemCallingUI([ZegoUIKitSignalingPlugin()]));

  await ZIMKit().init(
      appID: 1519377711,
      appSign:
          "3205f419ff097cb2c24f0d4268d1c7cd2b5a38a1f64dc5958a0a54d0a187c394");

  Stripe.publishableKey =
      "pk_live_51QASNDHrvHhkYUzEb7ga4eVDRbPXwM5EsWu1Cp7C11X9lQaknCHoo7bYz73vvphJYiZBvRMPScOTNpbZ7ssAwViI00tbjqcqAH";

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Message in a botlle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
            backgroundColor: const WidgetStatePropertyAll(
              Colors.teal,
            ),
            fixedSize: WidgetStatePropertyAll(
                Size.fromWidth(MediaQuery.of(context).size.width)),
            shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
          ),
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 10,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
          shadowColor: Colors.black12,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
