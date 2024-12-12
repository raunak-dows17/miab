import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:message_in_a_botlle/models/user_model.dart';
import 'package:message_in_a_botlle/utils/secure_storage.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// import 'package:zego_zimkit/zego_zimkit.dart';

// String _url = "https://miab.onrender.com/api";
String _url = "https://api.messageinabotlle.app/api";

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> signUp({
    required String firstName,
    required String lastname,
    required String email,
    required String mobile,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.post(Uri.parse("$_url/users"), body: {
        "firstName": firstName,
        "lastName": lastname,
        "email": email,
        "mobile": mobile,
        "password": password,
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 400) {
        state = state.copyWith(
          error: "User already exists",
          isLoading: false,
        );
      }

      if (response.statusCode == 201) {
        SecureStorage.storeTokens(responseData["token"]);

        final userResponse = await http.get(Uri.parse("$_url/users/me"),
            headers: {"Authorization": "Bearer ${responseData["token"]}"});

        final userData = json.decode(userResponse.body);
        final user = User.fromJson(userData);

        state = state.copyWith(
          user: user,
          isLoading: false,
        );

        // ZegoUIKitPrebuiltCallInvitationService().init(
        //   appID: 770575310,
        //   appSign:
        //       "35f243a352844308a18bdacc7d10caec384b9d0c3e56a6958d46cc87b10c0183" /*input your AppSign*/,
        //   userID: user.id,
        //   userName: "${user.firstName} ${user.lastName}",
        //   plugins: [ZegoUIKitSignalingPlugin()],
        //   requireConfig: (ZegoCallInvitationData data) {
        //     var config = (data.invitees.length > 1)
        //         ? ZegoCallType.videoCall == data.type
        //             ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
        //             : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        //         : ZegoCallType.videoCall == data.type
        //             ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        //             : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        //     config
        //       ..turnOnCameraWhenJoining = false
        //       ..turnOnMicrophoneWhenJoining = false
        //       ..useSpeakerWhenJoining = true;
        //     return config;
        //   },
        // );
        // await ZIMKit().connectUser(
        //     id: user.id, name: "${user.firstName} ${user.lastName}");
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Something went wrong',
        isLoading: false,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await http.post(Uri.parse("$_url/auth/login"), body: {
        "email": email,
        "password": password,
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        await SecureStorage.storeTokens(responseData["token"]);

        final userResponse = await http.get(
          Uri.parse("$_url/users/me"),
          headers: {"Authorization": "Bearer ${responseData["token"]}"},
        );

        final userData = json.decode(userResponse.body);
        final user = User.fromJson(userData);

        state = state.copyWith(
          user: user,
          token: responseData['token'],
          isLoading: false,
        );

        // ZegoUIKitPrebuiltCallInvitationService().init(
        //   appID: 770575310,
        //   appSign:
        //       "35f243a352844308a18bdacc7d10caec384b9d0c3e56a6958d46cc87b10c0183" /*input your AppSign*/,
        //   userID: user.id,
        //   userName: "${user.firstName} ${user.lastName}",
        //   plugins: [ZegoUIKitSignalingPlugin()],
        //   requireConfig: (ZegoCallInvitationData data) {
        //     var config = (data.invitees.length > 1)
        //         ? ZegoCallType.videoCall == data.type
        //             ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
        //             : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        //         : ZegoCallType.videoCall == data.type
        //             ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        //             : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

        //     // Modify your custom configurations here.
        //     config
        //       ..turnOnCameraWhenJoining = false
        //       ..turnOnMicrophoneWhenJoining = false
        //       ..useSpeakerWhenJoining = true;
        //     return config;
        //   },
        // );

        // await ZIMKit().connectUser(
        //     id: user.id, name: "${user.firstName} ${user.lastName}");
      }
    } catch (e) {
      state = state.copyWith(
        error: "An error occurred",
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
    state = AuthState();
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
