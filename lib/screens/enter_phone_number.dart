import 'package:flutter/material.dart';
import 'package:node_me/screens/otp_verification_scree.dart';
import 'package:node_me/widgets/auth_button.dart';
import 'package:node_me/widgets/text_field.dart';

class EnterPhoneNumber extends StatefulWidget {
  const EnterPhoneNumber({super.key});

  @override
  State<EnterPhoneNumber> createState() => _EnterPhoneNumberState();
}

class _EnterPhoneNumberState extends State<EnterPhoneNumber> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your phone number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                controller: phoneController,
                LabelText: 'phone number',
              ),
              const SizedBox(height: 20),

              CustomSimpleRoundedButton(
                onPressed: () {
                  // Navigate to OTP verification screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtpVerificationScree(),
                    ),
                  );
                },
                text: 'Enter OTP',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
