import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String firstName;
  final String lastName;
  final String mobile;
  final String avatar;
  final String id;

  const ChatScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.avatar,
    required this.id,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final messageController = TextEditingController();
  String messageValue = "";

  @override
  Widget build(BuildContext context) {
    return ZIMKitMessageListPage(
      conversationID: widget.id,
      appBarBuilder: (BuildContext context, AppBar appBar) {
        return AppBar(
          toolbarHeight: 78,
          backgroundColor: Colors.white,
          leading: const BackButton(
            color: Colors.teal,
          ),
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.avatar.isEmpty
                        ? "https://img.freepik.com/free-psd/3d-icon-social-media-app_23-2150049569.jpg?t=st=1733298836~exp=1733302436~hmac=1f15270d55a1c3142a5cbd171f3c553dc74b45bc25afb5e19257171d3339169e&w=740"
                        : widget.avatar),
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.firstName} ${widget.lastName}",
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.mobile,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ZegoSendCallInvitationButton(
              buttonSize: const Size(64, double.maxFinite),
              invitees: [
                ZegoUIKitUser(
                    id: widget.id,
                    name: "${widget.firstName} ${widget.lastName}"),
              ],
              isVideoCall: false,
              callID: widget.id,
              icon: ButtonIcon(
                icon: const Icon(
                  Icons.call,
                  color: Colors.teal,
                ),
              ),
            ),
            ZegoSendCallInvitationButton(
              buttonSize: const Size(64, double.maxFinite),
              invitees: [
                ZegoUIKitUser(
                    id: widget.id,
                    name: "${widget.firstName} ${widget.lastName}"),
              ],
              isVideoCall: true,
              callID: widget.id,
              icon: ButtonIcon(
                icon: const Icon(
                  Icons.videocam,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        );
      },
      conversationType: ZIMConversationType.peer,
      showMoreButton: false,
      showPickFileButton: false,
      messageInputMaxLines: 5,
      inputDecoration: const InputDecoration(
          hintText: "Write your message",
          border: OutlineInputBorder(borderSide: BorderSide.none)),
    );
  }
}
