import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:message_in_a_botlle/models/user_model.dart';
import 'package:message_in_a_botlle/utils/secure_storage.dart';
import 'package:zego_uikit_beauty_plugin/zego_uikit_beauty_plugin.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

// String _url = "https://48mz9gbq-5000.inc1.devtunnels.ms/api";
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

        await ZegoUIKitPrebuiltCallInvitationService().init(
          appID: 770575310,
          appSign:
              "35f243a352844308a18bdacc7d10caec384b9d0c3e56a6958d46cc87b10c0183",
          userID: user.id,
          userName: "${user.firstName} ${user.lastName}",
          plugins: [ZegoUIKitSignalingPlugin(), getBeautyPlugin()],
          requireConfig: (ZegoCallInvitationData data) {
            var config = (data.invitees.length > 1)
                ? ZegoCallInvitationType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                : ZegoCallInvitationType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

            config
              ..turnOnCameraWhenJoining =
                  ZegoCallInvitationType.videoCall == data.type
              ..turnOnMicrophoneWhenJoining = true
              ..useSpeakerWhenJoining =
                  ZegoCallInvitationType.videoCall == data.type;

            if (user.isPremium) {
              config.bottomMenuBar.buttons = [
                ZegoCallMenuBarButtonName.beautyEffectButton,
                ...config.bottomMenuBar.buttons,
              ];
            }

            // config.bottomMenuBar.buttons = user.isPremium
            //     ? [
            //         ZegoCallMenuBarButtonName.beautyEffectButton,
            //         ...config.bottomMenuBar.buttons,
            //       ]
            //     : [];

            config.beauty = ZegoBeautyPluginConfig(
              license: () =>
                  "96B90610C6C8452DC052D2ECFF1A35D7D117558B66DB57C400D5F032E7511946691260C774FD917B1428ED138560A0096290018DFBA34C8B9BFFADAE9D50D9EE7CC04B6C8B5CCFF752A4EB418AA1B1CA6922FCE370DF0C68AAF5B5A9D28FC54D795EAF9FFB4DD46013C51E4FB1E157D79AED4FD7C72639575490C95144F1908C8B0A7EBFCE26AE80CE46F3D3980602C6811C3EA5F6FE685BFD6A417473F0CDC11D54E1B394E97A57D7125C317D9DFCF3407F4B5F50BD35D961A31370B58A53DC267A429A0449D8452C35457524A2A38AE226C104CC54C422622C9E763984356DDFBD8018DCDF38B83765DA7228FE130A9FC7E27EF2E92F71838CD37325814CF5CD89C316553B401C1CC4EFC1BC1CDC829E86A206A2683E4EF05CED0BF7F76D098EBEAAD79D8E786F25E87CD98508C23449C11878B13309EB8E1CB9A1CBEE602C67580036E2F35322096B46A1D16FA9DF5AEFC39500723FBAC31DD653AA5A3B0F65746AF36FFD3F70D6836400F1E5BBB579D76BE1998A4748BBF7712D1FD725B97ED472C8E4F6BB94612DE6A294903084443DCC550BE5ED704E27DC9928C2D88D430ACDC5D263B8A662B4C4EC211822105541BCD01B617ED9B83D8B5153518DC80AE7FA821822FBD1883263B90A1C3C9722FAAD2E9A22591F98DD81901D0D96CA3CBE074574047C665F5AEAE8660DA067CE6D4E06D1F5570DFF7621E00C3CD75C80A68E74CB0AEF832BDD88189F402027FD1BF55A365C521C127B2BCCBDCF16480C0EF8B2F63B79776A621E277E781A600AF6BE549ABEB824C1D9491906E0181739E4FF04807E73C51B2B41F130419E207B52B137AB51698B7E4A84463CEA2AD052AA470CA0DAB3D70E90B44352CB15CB9C28F93CD2ECC28FC9835F9B9C0005763E458D54CAE0F6DBFC5A20EB2E88562FCA9C757E616A406657EE3B1B0A3D1EBE5DD0134E148A2FD1FCEA71FB5A10431430AA33580134EC6E0F692E216E4A2F6D5176C306ECBA14213E842B119AD8401AF078EADBF3231BC47B74E76DCEA91A96AA6DF7210B1583A6DE7DA2559CDA9039A19D8FD34A69EA53FD9985143620A7A743B82BE5CB4ABC831DD123026D883105748C971DDB9C5FC9B6BF907351925B60BDB28AD16EC9C291957125FEB0076C791193F3AAC3D3B662BD778E972BA116D3C45C39D3C2BD0BFB832A3A33916D437423ABABBF3ED81AFD33649B627EB3AB8EE062B3A891148B92EA81AF9E7B7F50A3192B43391C4C09858F94C98C8B674304BD289CF8E68C36135637A5A03F469A03DE56A93A4062C8BF2C1D7F4AC6156EDECB5AD275F1480E4DC035109DE89AAEDB912F2F789B67B94DA2771BC7910E19E280378E69A8E6935B25C415101BF6D7BD321C30FAF0155D2A736C1CA7F9098CE812EFCC079C835E89C23B9824BA0BFD462FE28D9799018935F20B5F4BBC6150092DF54EF97B738957A9AE8376E1961BB3A38640EDB02B15629CA312A6BE5C08D90AB2B477625934931A0A369E2A71D441A75395B7BC331419E7568CD030249BEB7B06D02B95B3FBFB9CF2E5BB1F1E5BE695E41BA7058EF751F35D82C7BBA116AAFA1B83D369D42600D29B0D7FE9E74319AC5D4A357E653F18D62EA2AF3E6394A000EBA36E364E391B7626F9A2DC9472ABB7308F33BE528547DB872A83A2FB5C68C975144AA36A96369108DD651C7E5BA71B00D79D2C39459D1E87FC3276C8591A6825C41A7B392741974728BE392620041BE269630F0A672444C3A47797E47A128C955E948A3BA2D55D386D66FF93103787B84A599A8874C5A4320267EB1E2A98DF33296FB4D8D46D75F5FA5686CED28BF0BE74DB7574519D682150542F81A29DA3091C17D1E1114A5E26E58AAC6354643120219112E7DC7ED232A150053B86F3DF7D61EDFD77E6D9485D91106CA9EFE7D9CCABC29A00C9948D00EA4DBF718DDE009995C2749F4CADB1F7FADBF85E4FFE5E80D7A8086813804DC382D46ABFEEF099CD968EBF04A159115E8A35AD858AD9AAA8B33565D67A3506FCB8953C2373FA86D1DFD1577C40537C19F740A1854523233BC2F63034CBC29500F8FD8C7049EBA94FAAC340B8859D0FE46869E3FA9101D205F5675174C5C1D08507968E6C8665D9C08510A2CB1C96B322280716DC41A118FCECA359B3123FB6D40BE4C7354EECE87D8100DC27A3EA791032351B44DFC0A239FF808BBBF70ADC6BB2FD117A9EE4",
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

//   Users premium feature
  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    final response = await http.post(
      Uri.parse('$_url/create-checkout-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': state.user!.email, 'amount': amount}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment intent');
    }
  }

  Future<void> _makeUserPremium(String price) async {
    final response = await http.put(
      Uri.parse('$_url/user/premium'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': state.user!.email, "amount": price}),
    );

    if (response.statusCode == 200) {
      await fetchUserProfile();
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to mark user as premium');
    }
  }

  Future<void> initiateStripePayment(BuildContext context, String price) async {
    try {
      final paymentIntentData = await _createPaymentIntent(double.parse(price));

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData["clientSecret"],
          merchantDisplayName: "Message in a botlle",
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment Successful"),
              ),
            )
          : null;

      await _makeUserPremium(price);
    } on StripeException catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${e.error.localizedMessage}')),
            )
          : null;
    } catch (e) {
      context.mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            )
          : null;
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
