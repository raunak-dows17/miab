import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:message_in_a_botlle/models/user_model.dart';
import 'package:message_in_a_botlle/utils/secure_storage.dart';
import 'package:zego_uikit_beauty_plugin/zego_uikit_beauty_plugin.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

String _url = "https://api.messageinabotlle.app/api";

class UserState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  UserState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      String? token = await SecureStorage.getIdToken();

      final response = await http.get(Uri.parse("$_url/users/me"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        final user = User.fromJson(json.decode(response.body));

        state = state.copyWith(
          user: user,
          isLoading: false,
        );

        ZegoUIKitPrebuiltCallInvitationService().init(
          appID: 770575310,
          appSign:
              "35f243a352844308a18bdacc7d10caec384b9d0c3e56a6958d46cc87b10c0183" /*input your AppSign*/,
          userID: user.id,
          userName: "${user.firstName} ${user.lastName}",
          plugins: [ZegoUIKitSignalingPlugin(), getBeautyPlugin()],
          requireConfig: (ZegoCallInvitationData data) {
            var config = (data.invitees.length > 1)
                ? ZegoCallType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                : ZegoCallType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

            config
              ..turnOnCameraWhenJoining =
                  ZegoCallType.videoCall == data.type ? true : false
              ..turnOnMicrophoneWhenJoining = true
              ..useSpeakerWhenJoining =
                  ZegoCallType.videoCall == data.type ? true : false;

            config.bottomMenuBarConfig.buttons = [
              ZegoCallMenuBarButtonName.beautyEffectButton,
              ...config.bottomMenuBarConfig.buttons,
            ];

            config.beautyConfig = ZegoBeautyPluginConfig(
              license: () =>
                  "8703113E9BB78501967706340138CB46C50B971A6822D9A2448E88A74E997354C21AAE693E044BDAC6326C9E7F021B77E3804CB5D3BC20D9B3658B1741C47F979EBFD134FFE940D479EE01E05881C02726E556D1FC08A76EFAF619444793BDB18A0051F6B6395DFD8847D6EA94739CCA7BEC5C28FEF40745964260CCD15B0260399577FFF45B3EADF8A66392495214DD55725603A20533999754660868052C59A9FA8AFA02072AE02C358EF74FBB3F2BB7E4FF62AA0F5615A5E2BD7CF2071E52F74997752A65B153593EBDACDC9C89955A72EF71AA436B93D007AF172CB08957747900DFFA487A394903C61849277C7D7135DBE3D669D17963E521786F26B93759B24CDD63F8FEDC47278D744BC6817B87061CC883B4AA08A1B3DF4C9C07A723C6F5DD61F1AC8C306342856F4FA62C7A976F9CE5C4AC61496FA69B7AE73B4294E9F6C480121F18095921D944D37C881DB7C78716A30CD0D32F030384B60257CCB4EA41835418F7EC675A478D24E1FD15C2E34A221008EF5ACB03C8098E977EDBAC44FA66CC40D95358EA0C0D85FB530AE87E307940E5FF498F76E94E7177A65B50903C915107EAD25537418881FD8B01D16B52450BD8DEFE9740BC43500BCFAC542C379EC641440BFFE7819FA2C57F2C95269BD96BA3E468ABD507C2F1A9AF24156C32C85391790E96912AA6072985ED71094641FD6CC36C44EF4DF9317D75974761B286055D558DE034F1A350F9F3C750E65500A6882852C0233DFE9F10C4A4C551FBD69853A4E8A4574FF266699BB28D471C1B33FF299B4ADD2972D81FFDE8555ACE2F9072E2619CFC7B98E96154218D454374FA3C57AF62FCB44A1CB6C3F6A75E2270B6B314E180921DDA838B2134C157954CB97118E6F45C31A6FF8644D64653C91841096248C9518642BBC3DC8BD653955C38368DF280939D0ABCA91952DF5814933D51C00354E6AFFCD507727C6EC96CA7F913C1B136A302F5FC80A7449CDFA3776640E41DE71EC38B3E105C539883190D82C324F6841121213E7797CEDE502D1B809839C76CC2DA6A25F5CC8756FBE7DDE2F455BCADD1403BA316DC49524B8350D44D915C5B7C34CB0438111B178CCD737876DA95862928AD7433FCF017845A871ED6AC8E401DE054C515101F19C32B64995746CE87F8B17C91FD3E802629C2F505CEAB01C71A6D3D6D30981B818EF0156363FD8FAAC234C7F2A1026D402986232D10EBF8C87BACB8A09BF294E72BA427CB59FD6D00A091E6A8CE387B88C1FE6E8DD73317DF0F34269EA2AFB67B914BDE28AD0A77D56805D83398C5174B1C5EDFAC96CF68A5F01EC525392E2BA45F966D3A3DCC5809A86242DE24E6D91B7E234F6FE2D096213FAB6B12211F0D40B941308222093CCEC450F13A51E5E51E4EB0D31DA0997E3ACC1F42CB14E46B407209D6988DA2E019DD8F863474B861C6F78C813EA2DB2F7845D89A7545B82CFD993C9C962FDCA35CDC5761128111E71E1D80D946D9F00663094E94CF946C509EBE1CF6AE47C99FD67BA9C258172802A53D1BA483621A20D71F39757F2277FBD86D45498DB730CF74C07D3CBE06B14F2F3BD83C4F444A01809D7CD4609D19E7ACE7D0E1C668BA47D69A59990E3D57EB4CAFBF1EAEECFBA32F8DA03AAE94F1390DA11AE692CC50C78DB135289CC505D88ECB07C60B5C32079D8282E890AC1459C90AF5C344E46388D133A4A75D2C147A3D6E148A0A98EE61423A2838E80E1B3EC39C10F9283BEE04FC2E40BA7D47F0BB3144776E6043B59EE151DCD0AFE1C6665DD0922992001C604FB49BAFD5EA68A404943BE139A59BE3566AE5151336BC3FA6218D5C4EC6E8D45D09ABF5C3AA2592D971EC509C625CB74E024E24F8D37D83C30F71978D48441C0901AD1D2C5E56138411410349C4F5316D6BF7335CC99242AB765DE6B88AB83E58640185463E26675FAF2B1E9461036825E00D56EBFD994549AEF024E86FCD55E6965AFFF36C20B774EF1FDE23A2E29B08DF39623DE365E6027F62201D97B64D542ADEBE4E70F7CFDBA3C3671E51ECF1BC9851FAA848759BBC3A1BC2A23F2A73A192D954113BADCBC8EB97B1D30A5BCE434DB7ABA52FDBA7E265D613F154D42C3D0FE40E74194D4BA5CFCB8C73E7A939535DFBE9B7786D9FABCE2A5F7AF667A4D46B78C9338E01E4D8B6201378B5B272A9E3671ACC111FAE832B74A65B4CC116D2D51910C5345B33BF361CBCCE7CC0C50DFFE47115D49DE9",
              effectsTypes: ZegoBeautyPluginConfig.beautifyEffectsTypes(
                    enableBasic: true,
                    enableAdvanced: true,
                    enableMakeup: true,
                    enableStyle: true,
                  ) +
                  ZegoBeautyPluginConfig.filterEffectsTypes() +
                  ZegoBeautyPluginConfig.stickersEffectsTypes() +
                  ZegoBeautyPluginConfig.backgroundEffectsTypes(),
              segmentationBackgroundImageName: "image1.jpg",
            );

            return config;
          },
        );

        await ZIMKit().connectUser(
            id: user.id, name: "${user.firstName} ${user.lastName}");
      }
    } catch (e) {
      state = state.copyWith(
        error: "An error Occurred ${e.toString()}",
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
    XFile? avatar,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      String? token = await SecureStorage.getIdToken();

      final request = http.MultipartRequest('PUT', Uri.parse("$_url/users/me"));

      request.headers["Authorization"] = "Bearer $token";
      request.fields["firstName"] = firstName;
      request.fields["lastName"] = lastName;
      request.fields["mobile"] = mobile;

      if (avatar != null) {
        request.files
            .add(await http.MultipartFile.fromPath("avatar", avatar.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final user = User.fromJson(jsonData["user"]);

        state = state.copyWith(
          user: user,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: "An error Occurred",
        isLoading: false,
      );
    }
  }

  ZegoUIKitBeautyPlugin getBeautyPlugin() {
    final plugin = ZegoUIKitBeautyPlugin();
    final config = ZegoBeautyParamConfig(
        ZegoBeautyPluginEffectsType.beautyBasicSmoothing, true,
        value: 80);
    final config1 = ZegoBeautyParamConfig(
        ZegoBeautyPluginEffectsType.backgroundMosaicing, true,
        value: 90);
    plugin.setBeautyParams([config, config1], forceUpdateCache: true);
    return plugin;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
