//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';
// class AddPaymentCardScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return AddPaymentCardScreenState();
//   }
// }
//
//
// class AddPaymentCardScreenState extends State<AddPaymentCardScreen> {
//   String cardNumber = '';
//   String expiryDate = '';
//   String cardHolderName = '';
//   String cvvCode = '';
//   bool isCvvFocused = false;
//   bool useGlassMorphism = false;
//   bool useBackgroundImage = false;
//   OutlineInputBorder? border;
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//
//
//
//
//   @override
//   void initState() {
//     border = OutlineInputBorder(
//       borderSide: BorderSide(
//         color: Colors.grey.withOpacity(0.7),
//         width: 2.0,
//       ),
//     );
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         resizeToAvoidBottomInset: false,
//         body:
//             Column(
//
//               children: <Widget>[
//
//                 SizedBox(height: 150,),
//
//                 CreditCardWidget(
//                   cardNumber: cardNumber,
//                   expiryDate: expiryDate,
//                   cardHolderName: cardHolderName,
//                   cvvCode: cvvCode,
//                   bankName: 'Axis Bank',
//                   showBackView: isCvvFocused,
//                   obscureCardNumber: true,
//                   obscureCardCvv: true,
//                   isHolderNameVisible: true,
//                   cardBgColor: Colors.black,
//                   isSwipeGestureEnabled: true,
//                   onCreditCardWidgetChange:
//                       (CreditCardBrand creditCardBrand) {},
//                   customCardTypeIcons: <CustomCardTypeIcon>[
//
//                   ],
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: <Widget>[
//                         CreditCardForm(
//                           formKey: formKey,
//                           obscureCvv: true,
//                           obscureNumber: true,
//                           cardNumber: cardNumber,
//                           cvvCode: cvvCode,
//                           isHolderNameVisible: true,
//                           isCardNumberVisible: true,
//                           isExpiryDateVisible: true,
//                           cardHolderName: cardHolderName,
//                           expiryDate: expiryDate,
//                           themeColor: Colors.blue,
//                           textColor: Colors.black,
//                           cardNumberDecoration: InputDecoration(
//                             labelText: 'Number',
//                             hintText: 'XXXX XXXX XXXX XXXX',
//                             hintStyle: const TextStyle(color: Colors.black),
//                             labelStyle: const TextStyle(color: Colors.black),
//                             focusedBorder: border,
//                             enabledBorder: border,
//                           ),
//                           expiryDateDecoration: InputDecoration(
//                             hintStyle: const TextStyle(color: Colors.black),
//                             labelStyle: const TextStyle(color: Colors.black),
//                             focusedBorder: border,
//                             enabledBorder: border,
//                             labelText: 'Expired Date',
//                             hintText: 'XX/XX',
//                           ),
//                           cvvCodeDecoration: InputDecoration(
//                             hintStyle: const TextStyle(color: Colors.black),
//                             labelStyle: const TextStyle(color: Colors.black),
//                             focusedBorder: border,
//                             enabledBorder: border,
//                             labelText: 'CVV',
//                             hintText: 'XXX',
//                           ),
//                           cardHolderDecoration: InputDecoration(
//                             hintStyle: const TextStyle(color: Colors.black),
//                             labelStyle: const TextStyle(color: Colors.black),
//                             focusedBorder: border,
//                             enabledBorder: border,
//                             labelText: 'Card Holder',
//                           ),
//                           onCreditCardModelChange: onCreditCardModelChange,
//                         ),
//                         const SizedBox(
//                           height: 20,
//                         ),
//
//
//
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               // primary: AppColors.greenColor
//                             // backgroundColor: const Color(0xff1b447b),
//                           ),
//                           child: Container(
//                             margin: const EdgeInsets.all(12),
//                             child: const Text(
//                               'Save',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontFamily: 'halter',
//                                 fontSize: 14,
//                                 package: 'flutter_credit_card',
//                               ),
//                             ),
//                           ),
//                           onPressed: ()async {
//                             if (formKey.currentState!.validate()) {
//                               print('valid!');
//
//
//                               await Get.find<AuthController>().storeUserCard(cardNumber, expiryDate, cvvCode, cardHolderName);
//
//                               Get.snackbar('Success', 'Your card is stored successfully');
//
//                             } else {
//                               print('invalid!');
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//
//
//     );
//   }
//
//   void onCreditCardModelChange(CreditCardModel? creditCardModel) {
//     setState(() {
//       cardNumber = creditCardModel!.cardNumber;
//       expiryDate = creditCardModel.expiryDate;
//       cardHolderName = creditCardModel.cardHolderName;
//       cvvCode = creditCardModel.cvvCode;
//       isCvvFocused = creditCardModel.isCvvFocused;
//     });
//   }
// }
// storeUserCard(String number, String expiry, String cvv, String name) async {
//   await FirebaseFirestore.instance
//       .collection('users')
//       .doc(FirebaseAuth.instance.currentUser!.uid)
//       .collection('cards')
//       .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});
//
//   return true;
// }
// List userCards = [];
// getUserCards() {
//   FirebaseFirestore.instance
//       .collection('users')
//       .doc(FirebaseAuth.instance.currentUser!.uid).collection('cards')
//       .snapshots().listen((event) {
//     userCards.value = event.docs;
//   });
// }