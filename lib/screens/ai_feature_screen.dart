import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:message_in_a_botlle/components/ai_plan_component.dart';

class AiFeatureScreen extends ConsumerStatefulWidget {
  const AiFeatureScreen({super.key});

  @override
  ConsumerState<AiFeatureScreen> createState() => _AiFeatureScreenState();
}

class _AiFeatureScreenState extends ConsumerState<AiFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'AI Features That Could Be Enabled By You',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    AiPlanComponent(
                      title: 'Standard Plan',
                      price: 'Free',
                      features: [
                        'Chat Encryption decryption (Your chat get encrypted and decrypted)',
                        'Audio call & video call (1 to 1 call connection)',
                        'Free Emojis (Provided some Emojis in web)',
                        'Media sharing (Can share Media within 10mb)',
                      ],
                      isStandardPlan: true,
                    ),
                    SizedBox(width: 64),
                    AiPlanComponent(
                      title: 'Advance AI Plan',
                      price: '9.99',
                      features: [
                        'Include All Features of Standard plans with advance AI features',
                        'AI Video Call Effect (Ai filters)',
                        'Media sharing (Can share Media within 10mb)',
                        "Encrypt your chat with AI (Encrypt and Decrypt the chat using AI)",
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
