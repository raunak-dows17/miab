import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:message_in_a_botlle/components/build_plan_component.dart';

class PlanDescriptionScreen extends ConsumerWidget {
  const PlanDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Select Your Time Period',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    BuildPlanComponent(
                      title: 'Monthly Plan',
                      price: '9.99',
                      time: "monthly",
                      features: [
                        'Include All Features of Standard plans with advance AI features',
                        'AI Video Call Effect (Ai filters)',
                        'Media sharing (Can share Media within 10mb)',
                        "Encrypt your chat with AI (Encrypt and Decrypt the chat using AI)",
                      ],
                      paymentLinks: {
                        'Domestic':
                            'https://www.instamojo.com/@k2kitsupport/l6630c104487b4aefa9bd815588cdc1e7/',
                        'International':
                            'https://buy.stripe.com/7sI4gY51w0qLclW9AK',
                      },
                    ),
                    SizedBox(height: 16),
                    BuildPlanComponent(
                      title: 'Quarterly Plan',
                      price: '26.97',
                      time: "quarterly",
                      features: [
                        'Include All Features of Standard plans with advance AI features',
                        'AI Video Call Effect (Ai filters)',
                        'Media sharing (Can share Media within 10mb)',
                        "Encrypt your chat with AI (Encrypt and Decrypt the chat using AI)",
                      ],
                      paymentLinks: {
                        'Domestic':
                            'https://www.instamojo.com/@k2kitsupport/l5073ae56337148339aaf1e7990ae9192/',
                        'International':
                            'https://buy.stripe.com/dR63cUfGac9t2Lm4gr',
                      },
                    ),
                    SizedBox(height: 16),
                    BuildPlanComponent(
                      title: 'Yearly Plan',
                      price: '95.90',
                      time: "year",
                      features: [
                        'Include All Features of Standard plans with advance AI features',
                        'AI Video Call Effect (Ai filters)',
                        'Media sharing (Can share Media within 10mb)',
                        "Encrypt your chat with AI (Encrypt and Decrypt the chat using AI)",
                      ],
                      paymentLinks: {
                        'Domestic':
                            'https://www.instamojo.com/@k2kitsupport/l2dd315e00c774b2eb8c22043523cc9a7/',
                        'International':
                            'https://buy.stripe.com/8wM00IgKe0qLadO00d',
                      },
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
