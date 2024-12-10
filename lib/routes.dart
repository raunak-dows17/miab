import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:message_in_a_botlle/main.dart';
import 'package:message_in_a_botlle/screens/ai_feature_screen.dart';
import 'package:message_in_a_botlle/screens/auth/loginscreen.dart';
import 'package:message_in_a_botlle/screens/auth/signupscreen.dart';
import 'package:message_in_a_botlle/screens/chat_screen.dart';
import 'package:message_in_a_botlle/screens/edit_profile_screen.dart';
import 'package:message_in_a_botlle/screens/homescreen.dart';
import 'package:message_in_a_botlle/screens/plan_description_screen.dart';
import 'package:message_in_a_botlle/utils/secure_storage.dart';

class HomePageRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final homePageRefreshNotifier = HomePageRefreshNotifier();

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: "/",
  routes: [
    GoRoute(
        path: "/",
        builder: (BuildContext context, GoRouterState state) =>
            const HomePage()),
    GoRoute(
        path: "/enable-ai",
        routes: [
          GoRoute(
              path: "plan",
              builder: (BuildContext context, GoRouterState state) =>
                  const PlanDescriptionScreen())
        ],
        builder: (BuildContext context, GoRouterState state) =>
            const AiFeatureScreen()),
    GoRoute(
      path: "/auth",
      redirect: (_, __) => null,
      routes: [
        GoRoute(
            path: "login",
            builder: (BuildContext context, GoRouterState state) =>
                const Loginscreen()),
        GoRoute(
            path: "signup",
            builder: (BuildContext context, GoRouterState state) =>
                const SignUpScreen()),
      ],
    ),
    GoRoute(
        path: "/edit-profile",
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen()),
    GoRoute(
      path: "/chat",
      builder: (BuildContext context, GoRouterState state) {
        final chatData = state.extra as Map<String, dynamic>;
        return ChatScreen(
          firstName: chatData['firstName'],
          lastName: chatData['lastName'],
          mobile: chatData['mobile'],
          avatar: chatData['avatar'],
          id: chatData['id'],
        );
      },
    ),
  ],
  redirect: (context, state) async {
    String? idToken = await SecureStorage.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      if (!state.matchedLocation.startsWith("/auth")) {
        return "/auth/login";
      }
    }
    return null;
  },
  refreshListenable: homePageRefreshNotifier,
);
