import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
            color: Color.fromRGBO(240, 240, 240, 1),
          ),
          height: MediaQuery.of(context).size.height,
          // width: MediaQuery.of(context).size.height * .99,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/pay_fav/Confirmation.gif',
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                ' Success!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Your order will be delivered soon. ',
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Thankyou! For choosing our app ',
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 17),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserHomeScreen(navBarIndex: 0,)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 198, 50, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
