import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:node_me/screens/otp_verification_scree.dart';
import 'package:node_me/utils/app_color.dart';
import 'package:node_me/widgets/custom_button.dart';
import 'package:node_me/widgets/text_field.dart';

class EnterPhoneNumber extends StatefulWidget {
  const EnterPhoneNumber({super.key});

  @override
  State<EnterPhoneNumber> createState() => _EnterPhoneNumberState();
}

class _EnterPhoneNumberState extends State<EnterPhoneNumber> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyPhoneNumber() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid phone number",
            style: TextStyle(color: AppColors.error),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Verification failed: ${e.message}",
              style: TextStyle(color: AppColors.error),
            ),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScree(
              verificationId: verificationId,
              phoneNumber: phone,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Enter Phone Number"))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFieldWidget(
                controller: phoneController,
                keyboardType: TextInputType.number,
                labelText: 'Phone Number',
              ),
              const SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : CustomSimpleRoundedButton(
                      onPressed: verifyPhoneNumber,
                      text: 'Send OTP',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
