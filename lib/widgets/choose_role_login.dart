import 'package:authentication/Screens/Provider%20Screens/provider_register_and_login.dart';
import 'package:authentication/Screens/User%20Screens/user_login_and_signup.dart';
import 'package:flutter/material.dart';


class ChooseRoleDialog extends StatefulWidget {
  const ChooseRoleDialog({super.key});

  @override
  ChooseRoleDialogState createState() => ChooseRoleDialogState();
}

class ChooseRoleDialogState extends State<ChooseRoleDialog> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Want to login as?"),
      content: SizedBox(
        height: 120, // Set your desired height here
        child: Column(
          children: [
            ListTile(
              title: const Text('User'),
              leading: Radio<String>(
                value: 'User',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Provider'),
              leading: Radio<String>(
                value: 'Provider',
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle the selected role, for example, navigate to the appropriate screen
            if (selectedRole == 'User') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserLoginAndSignUpScreen(signUpCheck: false),
                ),
              );
            } else if (selectedRole == 'Provider') {
              // Navigate to the provider login/sign-up screen
              // Replace the code below with your actual implementation
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderLoginAndSignUpScreen(signUpCheck: false),
                ),
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
