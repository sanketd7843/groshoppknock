import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/drawer.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Pages/Other/add_address.dart';
import 'package:groshop/Pages/User/profileedit.dart';
import 'package:groshop/Routes/routes.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/addressbean/showaddress.dart';
import 'package:groshop/beanmodel/signinmodel.dart';
import 'package:groshop/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  var nameControler = TextEditingController();
  var emailControler = TextEditingController();
  var phoneControler = TextEditingController();
  String userName;
  bool islogin = false;
  String emailAddress;
  String mobileNumber;
  String _image;
  List<ShowAllAddressMain> allAddressData = [];
  bool isAddressLoading = false;

  @override
  void initState() {
    super.initState();
    getProfileValue();
  }

  void getProfileValue() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('user_name');
      emailAddress = preferences.getString('user_email');
      mobileNumber = preferences.getString('user_phone');
      _image = '$imagebaseUrl${preferences.getString('user_image')}';
      nameControler.text = userName;
      emailControler.text = emailAddress;
      phoneControler.text = mobileNumber;
    });
    getAddressByUserId(userId);
    getProfileFromInternet(userId);
  }

  void getProfileFromInternet(dynamic userId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = myProfileUri;
    await http.post(url, body: {
      'user_id': '${userId}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if(signInData.status == "1" || signInData.status==1){
          var userId = int.parse('${signInData.data.user_id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.user_name}');
          prefs.setString("user_email", '${signInData.data.user_email}');
          prefs.setString("user_image", '${signInData.data.user_image}');
          prefs.setString("user_phone", '${signInData.data.user_phone}');
          prefs.setString("user_password", '${signInData.data.user_password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.user_city}');
          prefs.setString("user_area", '${signInData.data.user_area}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.app_update}');
          prefs.setString("reg_date", '${signInData.data.reg_date}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referral_code}');
          prefs.setString("reward", '${signInData.data.rewards}');
          setState(() {
            userName = prefs.getString('user_name');
            emailAddress = prefs.getString('user_email');
            mobileNumber = prefs.getString('user_phone');
            _image = '$imagebaseUrl${prefs.getString('user_image')}';
            nameControler.text = userName;
            emailControler.text = emailAddress;
            phoneControler.text = mobileNumber;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void getAddressByUserId(dynamic userId) async{
    setState(() {
      isAddressLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = showAllAddressUri;
    await http.post(url, body: {
      'user_id': '${userId}'
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        var js = jsonDecode(response.body) as List;
        if(js!=null && js.length>0){
          allAddressData = js.map((e) => ShowAllAddressMain.fromJson(e)).toList();
        }
      }
      setState(() {
        isAddressLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isAddressLoading = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      drawer: buildDrawer(context,userName,islogin,onHit: () {
        SharedPreferences.getInstance().then((pref){
          pref.clear().then((value) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
                  return GroceryLogin();
                }), (Route<dynamic> route) => false);
          });
        });
      }),
      appBar: AppBar(
        title: Text(
          locale.myAccount,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      locale.myProfile,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: 16, letterSpacing: 1, color: Color(0xffa9a9a9)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: kMainColor),
                          borderRadius: BorderRadius.circular(5.0)),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:(){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEdit()));
                    },
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                locale.profileclickupdate,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(
                                    color: kMainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          (_image!=null)?CachedNetworkImage(
                            imageUrl: '${_image}',
                            height: 100,
                            width: 120,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Align(
                              widthFactor: 50,
                              heightFactor: 50,
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Image.asset('assets/icon.png'),
                          ):Image(
                            image: AssetImage('assets/icon.png'),
                            height: 100,
                            width: 120,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),
                    EntryField(
                      controller: nameControler,
                      labelFontWeight: FontWeight.w400,
                      horizontalPadding: 0,
                      label: locale.fullName,
                      labelFontSize: 16,
                    ),
                    EntryField(
                      controller: emailControler,
                      labelFontWeight: FontWeight.w400,
                      horizontalPadding: 0,
                      label: locale.emailAddress,
                      labelFontSize: 16,
                    ),
                    EntryField(
                      controller: phoneControler,
                      labelFontWeight: FontWeight.w400,
                      horizontalPadding: 0,
                      label: locale.phoneNumber,
                      labelFontSize: 16,
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey[100],
                thickness: 10,
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      locale.myAddresses,
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: 16, letterSpacing: 1, color: Color(0xffa9a9a9)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    (!isAddressLoading && allAddressData!=null && allAddressData.length>0)?
                    ListView.builder(
                      itemCount: allAddressData.length,
                        shrinkWrap: true,
                        primary: false,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context,index){
                      return buildAddressTile(context,allAddressData[index].type,allAddressData[index].data);
                    }):Container(
                      alignment: Alignment.center,
                      child: (isAddressLoading)?Align(
                        widthFactor: 50,
                        heightFactor: 50,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ):Text(locale.noaddressfound),
                    )
                    // buildAddressTile(
                    //     locale.home,
                    //     '1124, Patestine Street, Jackson Tower,\nNear City Garden, New York, USA'
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // buildAddressTile(
                    //     locale.office,
                    //     '1124, Patestine Street, Jackson Tower,\nNear City Garden, New York, USA'
                    // ),
                  ],
                ),
              ),
              // Spacer(),
              Divider(
                thickness: 3,
                color: Colors.transparent,
              ),
              CustomButton(
                label: locale.addAddress.toUpperCase(),
                onPress: AddAddressPage(),
                action: () async{
                  print('action success!');
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  getAddressByUserId(pref.getInt('user_id'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAddressTile(BuildContext context, String heading,List<AddressData> address) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,),
          ),
          SizedBox(height: 10,),
          ListView.builder(
            itemCount: address.length,
              shrinkWrap: true,
              primary: false,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
              AddressData addData = address[index];
              String addressshow = 'Name - ${addData.receiver_name}\nContact Number - ${addData.receiver_phone}\n${addData.house_no}${addData.landmark}${addData.society}${addData.city}(${addData.pincode})${addData.state}';
            return Row(
              children: [
                Expanded(
                    child: Text(
                        addressshow,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 14),
                    )
                ),
                IconButton(icon: Icon(
                  Icons.edit,
                  color: Color(0xff686868),
                  size: 20,
                ), onPressed: () async{
                  SharedPreferences preferences = await SharedPreferences.getInstance();
                  dynamic userId = preferences.getInt('user_id');
                  Navigator.of(context).pushNamed(PageRoutes.editAddress,arguments: {
                    'address_d':addData,
                  }).then((value){
                    getAddressByUserId(userId);
                  }).catchError((e){
                    getAddressByUserId(userId);
                  });
                }),
              ],
            );
          })
        ],
      ),
    );
  }
}
