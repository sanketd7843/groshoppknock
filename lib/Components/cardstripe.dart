import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:stripe_payment/stripe_payment.dart';

class MyStripeCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyStripeCardState();
  }
}

class MyStripeCardState extends State<MyStripeCard> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(null);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(locale.creditdebit),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CreditCardForm(
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cardNumberDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Number',
                          hintText: 'XXXX XXXX XXXX XXXX',
                        ),
                        expiryDateDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Expired Date',
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        cardHolderDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Card Holder',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const Text(
                            'Pay',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'halter',
                              fontSize: 14,
                              package: 'flutter_credit_card',
                            ),
                          ),
                        ),
                        color: const Color(0xff1b447b),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            print('valid!');
                            List<String> dated = expiryDate.split('/');
                            CreditCard creditCardPay = CreditCard(
                                number: cardNumber,
                                expMonth: int.parse('${dated[0]}'),
                                expYear: int.parse('${dated[1]}'),
                                cvc: cvvCode,
                                name: cardHolderName);
                            Navigator.of(context).pop(creditCardPay);
                          } else {
                            print('invalid!');
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
