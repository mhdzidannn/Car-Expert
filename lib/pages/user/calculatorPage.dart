import 'dart:math';
import 'package:carexpert/model/carLogo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CalculatorPage extends StatefulWidget {

  final int realCarPrice;
  final bool realCarStatus;

  CalculatorPage({ Key key,  this.realCarPrice, this.realCarStatus}) : super (key:key);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}


class _CalculatorPageState extends State<CalculatorPage> {

  String loanResult = '0.00';

  String loanResultCIMB = '0.00';
  String loanResultMaybank = '0.00';
  String loanResultPPB = '0.00';

  String cimbLoanInterest = '4.45';
  String maybankLoanInterest = '3.40';
  String pbeLoanInterest = '4.10';

  double tenure = 5;        //default placeholder, for all banks as well
  double interest = 3.55;    //default placeholder
  int carPrice;             //get from car detail page
  double depositValue;
  bool carStatus = true;  // new or used car

  final _formKey = GlobalKey<FormState>();
  
//uncomment below when implementing value from buy page
  @override
  void initState(){
    carPrice = widget.realCarPrice;     //to receive default car value from buy page
    carStatus = widget.realCarStatus;   //to receive default car status from buy page
    super.initState();
  }

  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Calculator', style: TextStyle(
          fontSize: 20
        ),
        ),
      ),

      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget> [
                upperBox(),
                carPriceForm(),
                depositAmountForm(),
                repaymentSlider(),
                interestSlider(),
                resultOfCalculation(),
                textForBanks(),
                listOfBanks(),
              ]
            ),
          )
        ],
      ),
    );
  }


  Widget upperBox(){
    return Stack(
      children: <Widget>[

        Container(
          height: 112,
          decoration: BoxDecoration(
            color: const Color(0xff7c94b6),
            image: const DecorationImage(
              image: AssetImage('assets/images/header.jpg'),
                fit: BoxFit.fitWidth,
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: 20, right:10, top:30, bottom:20),
          child: Text('Get the best rates using our Malaysia \nLoan Calculator and apply for Car \nLoans. It\'s quick, easy and convenient!',
            style: TextStyle(
              color: Colors.white
            )
          ),
        ),
      ] 
    );
  }


  Widget carPriceForm(){
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Car Price',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold
            ),),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[],
            maxLines: 1,
            decoration: InputDecoration(
                          prefixText: 'RM ',
                          hintText: 'Enter the price',
                        ),
            initialValue: carPrice.toStringAsFixed(2),
            onChanged: (value) => setState(() => carPrice = int.parse(value.toString())),
          ),

        ],
      )
    );
  }


  Widget depositAmountForm(){
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Deposit Amount',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold
            ),),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[],
            maxLines: 1,
            decoration: InputDecoration(
                          prefixText: 'RM ',
                          hintText: 'Enter the deposit amount',
                        ),
            initialValue: initialDepositValue.toStringAsFixed(2),        
            onChanged: (value) => setState(() => depositValue = double.parse(value.toString()) ),
            validator: (value) {
              if (double.parse(value.toString()) > carPrice) {
                return 'Value of deposit must be less than car price';
              }
              return null;
            },
            
            
          ),
          
        ],
      )
    );
  }


  Widget repaymentSlider(){
        return Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

            RichText(
                text: TextSpan(
                  text: 'Repayment Period: ',
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: '$tenure years',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  ]
                ),
            ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue[500],
              inactiveTrackColor: Colors.grey[400],
              trackShape: RectangularSliderTrackShape(),
              trackHeight: 3.0,
              thumbColor: Colors.blueAccent,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9.0),
              overlayColor: Colors.blue.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
            ),
            child: Slider(
              value: tenure,
              min: 1,
              max: 9,
              divisions: 8,
              label: '$tenure',
              onChanged: (value) {
                setState( () {
                 tenure = value;
                },);
              },
            ),
          ), 
        ],
      )
    );
  }


  Widget interestSlider(){
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
           RichText(
                text: TextSpan(
                  text: 'Interest Rate: ',
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                  children: <TextSpan>[
                    TextSpan(
                      text: '$interest%',
                      style: TextStyle(fontWeight: FontWeight.normal)),
                  ]
                ),
            ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue[500],
              inactiveTrackColor: Colors.grey[400],
              trackShape: RectangularSliderTrackShape(),
              trackHeight: 3.0,
              thumbColor: Colors.blueAccent,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9.0),
              overlayColor: Colors.blue.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
            ),
            child: Slider(
              value: interest,
              min: 1.0,
              max: 5.0,
              divisions: 40,
              label: '$interest',
              onChanged: (value) {
                setState( () {
                 interest = value;
                },
              );
              },
            ),
          ), 
        ],
      )
    );
  }


  Widget resultOfCalculation(){
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 30, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
            
          Center(
            child: RaisedButton(
              //onPressed: loanCalculation,
              onPressed: (){
                if (_formKey.currentState.validate()){
                  loanCalculation();
                } 
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              padding: EdgeInsets.all(0.0),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                  ),
                    borderRadius: BorderRadius.all(Radius.circular(80.0)),
                ),
                child: Container(
                  constraints: BoxConstraints(minWidth: 140.0, minHeight: 45.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Calculate',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
              
          SizedBox(
            height: 50
          ),
          
          Text('Monthly Installment:',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),

          SizedBox(
            height: 15
          ),

          Text('RM ${loanResult.toString().replaceAllMapped(regPrice, mathFuncPrice)}',
          style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w900,
              //fontStyle: FontStyle.italic,
              fontFamily: 'Open Sans',
              fontSize: 40,
            ),
          ),

          SizedBox(
            height: 15
          ),
          
          // Text('*Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.',
          // style: TextStyle(
          //     fontSize: 14
          //   ),
          // ),
          
          // SizedBox(
          //   height: 30
          // ),

        ],
      ),
      );
  }


  Widget textForBanks(){
    return Column(children: <Widget>[
      
      Padding(
        padding: const EdgeInsets.only(right: 50.0),
        child: Text('List of recommended banks to apply loan:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),

          SizedBox(
            height: 10
          ),

          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 60.0),
            child: RichText(
                text: TextSpan(
                  text: '*',
                  style: TextStyle(fontSize: 13, color: Colors.red),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Rates are from RinggitPlus and subjected to change by the bank from time to time',
                      style: TextStyle(color: Colors.black)),
                  ]
                ),
            ),
          ),

          SizedBox(
            height: 10
          ),

    ],
  );

  }


  Widget listOfBanks(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[

          //cimb bank
          Container(
            color: Colors.grey[200],
            height: 175,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 55.0, left:20.0, top: 20),
                        child: Text('Bank Rates', style: TextStyle(fontSize: 16),),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, top: 20),
                        child: Text('Monthly Repayment', style: TextStyle(fontSize: 16),),
                      ),     
                  ],
                ),

                Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 55.0, left:20.0, top: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: "$cimbLoanInterest%",
                            style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red)),
                               ]
                              ),
                          ),
                        ),

                    Padding(
                        padding: const EdgeInsets.only(left: 45.0, top: 5.0),
                        child: Text('RM ${loanResultCIMB.toString().replaceAllMapped(regPrice, mathFuncPrice)}', style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold,))
                        ),
                  ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/images/cimbBank.png',
                          height: 100,
                          width: 160,
                          fit: BoxFit.fitWidth,
                        ),

                      OutlineButton(
                        onPressed: (){
                          _launchURL('https://www.cimb.com.my/en/personal/day-to-day-banking/financing/auto-financing.html');
                        },
                        child: Text("Apply",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                        color: Colors.blueAccent,
                        textColor: Colors.blue[700],
                        borderSide: BorderSide(color: Colors.blue[700]),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 80)
                      ),
                    ],
                  )
              ],
            ),
          ),

          SizedBox(
              height: 25
          ),

          //maybank
          Container(
            color: Colors.grey[200],
            height: 175,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 55.0, left:20.0, top: 20),
                        child: Text('Bank Rates', style: TextStyle(fontSize: 16),),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, top: 20),
                        child: Text('Monthly Repayment', style: TextStyle(fontSize: 16),),
                      ),     
                  ],
                ),

                Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 55.0, left:20.0, top: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: '$maybankLoanInterest%',
                            style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red)),
                               ]
                              ),
                          ),
                        ),

                    Padding(
                        padding: const EdgeInsets.only(left: 45.0, top: 5.0),
                        child: Text('RM ${loanResultMaybank.toString().replaceAllMapped(regPrice, mathFuncPrice)}', style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold,))
                        ),
                  ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/images/maybank.png',
                          height: 100,
                          width: 160,
                          fit: BoxFit.fitWidth,
                        ),

                      OutlineButton(
                        onPressed: () {
                           _launchURL('https://www.maybank2u.com.my/mbb_info/m2u/public/personalList04.do?channelId=LOA-Loans&programId=LOA03-CarLoans&chCatId=/mbb/Personal/LOA-Loans');
                        },
                        child: Text("Apply",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                        color: Colors.blueAccent,
                        textColor: Colors.blue[700],
                        borderSide: BorderSide(color: Colors.blue[700]),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 80)
                      ),
                    ],
                  )
              ],
            ),
          ),

          SizedBox(
              height: 25
          ),

          //public bank
          Container(
            color: Colors.grey[200],
            height: 175,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 55.0, left:20.0, top: 20),
                        child: Text('Bank Rates', style: TextStyle(fontSize: 16),),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, top: 20),
                        child: Text('Monthly Repayment', style: TextStyle(fontSize: 16),),
                      ),     
                  ],
                ),

                Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 55.0, left:20.0, top: 5.0),
                        child: RichText(
                          text: TextSpan(
                            text: '$pbeLoanInterest%',
                            style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red)),
                               ]
                              ),
                          ),
                        ),

                    Padding(
                        padding: const EdgeInsets.only(left: 45.0, top: 5.0),
                        child: Text('RM ${loanResultPPB.toString().replaceAllMapped(regPrice, mathFuncPrice)}', style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold,))
                        ),
                  ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/images/publicBank.png',
                          height: 100,
                          width: 160,
                          fit: BoxFit.fitWidth,
                        ),

                      OutlineButton(
                        onPressed: () {
                           _launchURL('https://www.pbebank.com/Personal-Banking/Banking/Loan/Vehicle-Financing/Vehicle-Financing.aspx');
                        },
                        child: Text("Apply",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                        color: Colors.blueAccent,
                        textColor: Colors.blue[700],
                        borderSide: BorderSide(color: Colors.blue[700]),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 80)
                      ),
                    ],
                  )
              ],
            ),
          ),

          
        ]
      ),
    );
  }


 loanCalculation(){
  //input amortization formula here

    double result;
    double resultCimb;
    double resultMaybank;
    double resultPpb;

    double cimb = 4.45 / 12 /100;
    double maybank = 3.40 / 12 /100;
    double ppb = 4.10 / 12 /100;

    int p = carPrice;                //principal
    double r = interest / 12 / 100;     //interest
    double n =  tenure * 12;            //tenure in months

    result = (p * r * pow((1+r), n) / ( pow((1+r),n) -1));
    resultCimb = (p * cimb * pow((1+cimb), n) / ( pow((1+cimb),n) -1));
    resultMaybank = (p * maybank * pow((1+maybank), n) / ( pow((1+maybank),n) -1));
    resultPpb = (p * ppb * pow((1+ppb), n) / ( pow((1+ppb),n) -1));

    setState(() {
      loanResult = result.toStringAsFixed(2);
      loanResultCIMB = resultCimb.toStringAsFixed(2);
      loanResultMaybank = resultMaybank.toStringAsFixed(2);
      loanResultPPB = resultPpb.toStringAsFixed(2);
    });
    
    return result;
}


 Future _launchURL(dynamic link) async {
  String url = link;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
 }

  
  double get initialDepositValue{
    return carPrice * 10/100;
  }


  double get principalAmount{
    return carPrice - depositValue;
  }

}
