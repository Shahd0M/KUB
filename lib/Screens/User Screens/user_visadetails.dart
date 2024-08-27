import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisaDetails extends StatefulWidget {
  @override
  _VisaDetailsState createState() => _VisaDetailsState();
}

class _VisaDetailsState extends State<VisaDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardnumber = TextEditingController();
  final TextEditingController _expirydate = TextEditingController();
  final TextEditingController _CVV = TextEditingController();
  final TextEditingController _cardholder = TextEditingController();


  List<Map<String, String>> visadetails = [];

  void _addvisadetails() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        visadetails.add({
          'Card number': _cardnumber.text,
          'Expiry date': _expirydate.text,
          'CVV': _CVV.text,
          'Card holder': _cardholder.text,
        });
        _cardnumber.clear();
        _expirydate.clear();
        _CVV.clear();
        _cardholder.clear();
      });
    }
  }

  void _savevisa() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').add({
        'visa details': visadetails,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User Visa Saved')));
        _formKey.currentState!.reset();
        setState(() {
          visadetails = [];
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save visa data: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cardnumber,
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expirydate,
                decoration: InputDecoration(labelText: 'Expiry Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expiry date ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _CVV,
                decoration: InputDecoration(labelText: 'CVV'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the CVV';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cardholder,
                decoration: InputDecoration(labelText: 'Card Holder'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of card holder';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addvisadetails,
                child: Text('Add visa'),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: visadetails.length,
                  itemBuilder: (context, index) {
                    final visadetail = visadetails[index];
                    return ListTile(
                      title: Text(visadetail['Card Number'] ?? ''),
                      subtitle: Text(
                          '${visadetail['Expiry date']}, ${visadetail['CVV']}'
                              ' ${visadetail['Card holder']}, '),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _savevisa,
                child: Text('Save User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
