import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:node_me/screens/home_screen.dart';
import 'package:node_me/utils/app_color.dart';
import 'package:node_me/widgets/auth_button.dart';
import 'package:node_me/widgets/text_field.dart';

class OtpVerificationScree extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScree({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScree> createState() => _OtpVerificationScreeState();
}

class _OtpVerificationScreeState extends State<OtpVerificationScree> {
  final TextEditingController otpController = TextEditingController();
  bool isVerifying = false;

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid 6-digit OTP",
            style: TextStyle(color: AppColors.error),
          ),
        ),
      );
      return;
    }

    try {
      setState(() {
        isVerifying = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ Navigate to Profile Setup or Home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP verification failed: ${e.message}",
            style: TextStyle(color: AppColors.error),
          ),
          backgroundColor: AppColors.card,
        ),
      );
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
                'Enter the OTP sent to ${widget.phoneNumber}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFieldWidget(
                controller: otpController,
                keyboardType: TextInputType.number,
                labelText: '6-digit OTP',
              ),
              const SizedBox(height: 20),
              isVerifying
                  ? CircularProgressIndicator()
                  : CustomSimpleRoundedButton(
                      onPressed: verifyOtp,
                      text: 'Verify OTP',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
