import 'package:flutter/material.dart';
import 'package:node_me/widgets/auth_button.dart';
import 'package:node_me/widgets/text_field.dart';

class OtpVerificationScree extends StatefulWidget {
  const OtpVerificationScree({super.key});

  @override
  State<OtpVerificationScree> createState() => _OtpVerificationScreeState();
}

class _OtpVerificationScreeState extends State<OtpVerificationScree> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to previous screen
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your OTP',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFieldWidget(controller: phoneController, LabelText: 'OTP'),
              const SizedBox(height: 20),
              CustomSimpleRoundedButton(
                onPressed: () {
                  // Handle OTP verification logic here
                },
                text: 'Verify OTP',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
