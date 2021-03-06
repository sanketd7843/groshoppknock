import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:groshop/Components/custom_button.dart';
import 'package:groshop/Components/entry_field.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';
import 'package:groshop/baseurl/baseurlg.dart';
import 'package:groshop/beanmodel/citybean.dart';
import 'package:groshop/beanmodel/statebean.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  TextEditingController pincodeC = TextEditingController();
  TextEditingController stateC = TextEditingController();
  TextEditingController addressLine1C = TextEditingController();
  TextEditingController addressLine2C = TextEditingController();
  TextEditingController houseNumberC = TextEditingController();
  TextEditingController receiverNameC = TextEditingController();
  TextEditingController receiverPhoneC = TextEditingController();

  bool isPinE = false;
  bool isStateE = false;
  bool addresslineE = false;
  bool isHouseE = false;
  bool isRNameE = false;
  bool isRContactE = false;
  bool isCityE = false;
  bool isSocietyE = false;

  String isPinT = '--';
  String isStateT = '--';
  String addresslineT = '--';
  String isHouseT = '--';
  String isRNameT = '--';
  String isRContactT = '--';
  String isCityT = '--';
  String isSocietyT = '--';

  bool isSavingAddress = false;
  bool isBack = false;

  String addressType = 'Home';
  List<String> addressTypeList = ['Home','Office','Others'];

  bool isHideType = true;

  TextEditingController titleCon = TextEditingController();

  bool isCameraMove = false;

  bool getErrorStatus(
      bool isPinE,
      bool isStateE,
      bool addresslineE,
      bool isHouseE,
      bool isRNameE,
      bool isRContactE,
      bool isCityE,
      bool isSocietyE) {
    print('${isPinE}');
    if (isPinE) {
      setState(() {
        this.isPinE = true;
        isPinT = 'Enter your pincode/zipcode please.';
      });
    } else {
      setState(() {
        if (this.isPinE) {
          this.isPinE = false;
          isPinT = '--';
        }
      });
    }
    if (isStateE) {
      setState(() {
        this.isStateE = true;
        isStateT = 'Enter your state please.';
      });
    } else {
      setState(() {
        if (this.isStateE) {
          this.isStateE = false;
          isStateT = '--';
        }
      });
    }
    if (addresslineE) {
      setState(() {
        this.addresslineE = true;
        addresslineT = 'Enter your address please.';
      });
    } else {
      setState(() {
        if (this.addresslineE) {
          this.addresslineE = false;
          addresslineT = '--';
        }
      });
    }
    if (isHouseE) {
      setState(() {
        this.isHouseE = true;
        isHouseT = 'Enter your house/flat number please.';
      });
    } else {
      setState(() {
        if (this.isHouseE) {
          this.isHouseE = false;
          isHouseT = '--';
        }
      });
    }
    if (isRNameE) {
      setState(() {
        this.isRNameE = true;
        isRNameT = 'Enter your receiver name please.';
      });
    } else {
      setState(() {
        if (this.isRNameE) {
          this.isRNameE = false;
          isRNameT = '--';
        }
      });
    }
    if (isRContactE) {
      setState(() {
        this.isRContactE = true;
        isRContactT = 'Enter your receiver contact number please.';
      });
    } else {
      setState(() {
        if (this.isRContactE) {
          this.isRContactE = false;
          isRContactT = '--';
        }
      });
    }
    if (isCityE) {
      setState(() {
        this.isCityE = true;
        isCityT = 'please select your city to save address.';
      });
    } else {
      setState(() {
        if (this.isCityE) {
          this.isCityE = false;
          isCityT = '--';
        }
      });
    }
    if (isSocietyE) {
      setState(() {
        this.isSocietyE = true;
        isSocietyT = 'please select your socity to save address.';
      });
    } else {
      setState(() {
        if (this.isSocietyE) {
          this.isSocietyE = false;
          isSocietyT = '--';
        }
      });
    }
    return (isPinE &&
        isStateE &&
        addresslineE &&
        isHouseE &&
        isRNameE &&
        isRContactE &&
        isCityE &&
        isSocietyE);
  }

  bool isLoading = true;
  bool isVisbile = false;
  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(40.866813, 34.566688),
    zoom: 5.151926,
  );
  String currentAddress = "";
  Address address;
  final scrollController = ScrollController();

  bool isCityLoading = false;
  bool isSocityLoading = false;

  String selectCity = 'Select city';
  String selectSocity = 'Select Society/Area';
  List<CityDataBean> cityList = [];
  List<StateDataBean> socityList = [];
  CityDataBean cityData;
  StateDataBean socityData;

  bool isCityHide = true;
  bool isSocityHide = true;
  Completer<GoogleMapController> _controller = Completer();

  Future<void> _goToTheLake(lat, lng) async {
    final CameraPosition _kLake = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    titleCon.text = addressType;
    _getLocation();
  }

  void _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        Timer(Duration(seconds: 5), () async {
          double lat = position.latitude;
          double lng = position.longitude;
          final coordinates = new Coordinates(lat, lng);
          await Geocoder.local
              .findAddressesFromCoordinates(coordinates)
              .then((value) {
            for (int i = 0; i < value.length; i++) {
              if (value[i].locality != null && value[i].locality.length > 0) {
                setState(() {
                  currentAddress = value[0].addressLine;
                  address = value[0];
                  _goToTheLake(lat, lng);
                });
                break;
              }
            }
          });
        });
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  void _getCameraMoveLocation(LatLng data) async {
    Timer(Duration(seconds: 1), () async {
      lat = data.latitude;
      lng = data.longitude;
      final coordinates = new Coordinates(data.latitude, data.longitude);
      await Geocoder.local
          .findAddressesFromCoordinates(coordinates)
          .then((value) {
        for (int i = 0; i < value.length; i++) {
          if (value[i].locality != null && value[i].locality.length > 0) {
            if(!isBack){
              setState(() {
                currentAddress = value[0].addressLine;
                address = value[0];
                kGooglePlex= CameraPosition(
                    bearing: 192.8334901395799,
                    target: LatLng(lat, lng),
                    tilt: 59.440717697143555,
                    zoom: 20.151926040649414);
              });
            }
            break;
          }
        }
      });
    });
  }

  void getMapLoc() async {
    _getCameraMoveLocation(LatLng(lat, lng));
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppBar(
                  title: Text(
                    locale.addAddress,
                    style: TextStyle(fontSize: 18, color: kMainTextColor),
                  ),
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        if (isVisbile) {
                          setState(() {
                            isVisbile = false;
                          });
                        } else {
                          setState(() {
                            isBack = true;
                          });
                          Navigator.of(context).pop();
                        }
                      }),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: kGooglePlex,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        buildingsEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          print('on map created once call');
                          _controller.complete(controller);
                        },
                        onCameraIdle: () async{
                          print('done moving');
                          setState(() {
                            isCameraMove = false;
                          });
                          if(!isCameraMove){
                            print('data location \n - $lat - $lng');
                            getMapLoc();
                          }
                          // try{
                          //   if(lat!=null && lng!=null){
                          //     getMapLoc();
                          //   }
                          // }catch(e){
                          //   print(e);
                          // }
                        },
                        onCameraMove: (post) {
                          print('camera is moving');
                          lat = post.target.latitude;
                          lng = post.target.longitude;
                        },
                        onCameraMoveStarted: (){
                          print('camera is start moving');
                          isCameraMove = true;
                        },
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 36.0),
                            child: Image.asset(
                              'assets/map_pin.png',
                              height: 36,
                            ),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Icon(
                            Icons.check_box,
                            size: 20,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Flexible(
                        child: EntryField(
                          horizontalPadding: 0,
                          labelFontSize: 15,
                          labelFontWeight: FontWeight.w400,
                          readOnly: true,
                          label: locale.addressTitle,
                          controller: titleCon,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 20.0, left: 12, right: 12),
                  child: GestureDetector(
                    onTap: () {
                      if (address != null) {
                        pincodeC.text = address.postalCode;
                        stateC.text = address.adminArea;
                        addressLine1C.text = address.addressLine;
                        setState(() {
                          houseNumberC.clear();
                          receiverNameC.clear();
                          receiverPhoneC.clear();
                          addressLine2C.clear();
                          isPinE = false;
                          isStateE = false;
                          addresslineE = false;
                          isRContactE = false;
                          isRNameE = false;
                          isCityE = false;
                          isSocietyE = false;
                          isPinT = '--';
                          isStateT = '--';
                          addresslineT = '--';
                          isRContactT = '--';
                          isRNameT = '--';
                          isCityT = '--';
                          isSocietyT = '--';
                          isVisbile = !isVisbile;
                        });
                        hitCityData(context);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 20),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            '$currentAddress',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomButton(
                  onTap: () {
                    if (!isSavingAddress) {
                      setState(() {
                        isSavingAddress = true;
                      });
                      if (!getErrorStatus(
                          (pincodeC.text.toString().length < 1),
                          (stateC.text.toString().length < 1),
                          (addressLine1C.text.toString().length < 1),
                          (houseNumberC.text.toString().length < 1),
                          (receiverNameC.text.toString().length < 1),
                          (receiverPhoneC.text.toString().length < 1),
                          (cityData == null),
                          (socityData == null))) {
                        addAddress();
                      } else {
                        setState(() {
                          isSavingAddress = false;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
            Positioned(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                bottom: 60.0,
                child: (!isSavingAddress)
                    ? Visibility(
                        visible: isVisbile,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0)),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.7,
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                            child: Scrollbar(
                              controller: scrollController,
                              isAlwaysShown: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                controller: scrollController,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: kRedColor,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isVisbile = false;
                                          });
                                        },
                                      ),
                                    ),
                                    DropdownAType(
                                        context,
                                        heading: 'Select Address Type',
                                        hint: addressType,
                                        typeList: addressTypeList,
                                        callBackDrop: (){
                                      setState(() {
                                        isHideType = !isHideType;
                                      });
                                    },hideCallBack: (value){
                                      setState(() {
                                        isHideType = !isHideType;
                                        addressType = value;
                                      });
                                    },isHide: isHideType),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'Receiver Name',
                                        hint: 'Enter Receiver Name',
                                        controller: receiverNameC,
                                        inputType: TextInputType.text,
                                        isloading: isLoading,
                                        isError: isRNameE,
                                        error: isRNameT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'Receiver Contact Number',
                                        hint: 'Enter Receiver Contact Number',
                                        controller: receiverPhoneC,
                                        inputType: TextInputType.number,
                                        isloading: isLoading,
                                        isError: isRContactE,
                                        error: isRContactT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    DropDownCityAddress(context,
                                        heading: 'City',
                                        hint: selectCity,
                                        cityList: cityList,
                                        isloading: isCityLoading,
                                        isHide: isCityHide, callBackDrop: () {
                                      print('done');
                                      setState(() {
                                        isCityHide = !isCityHide;
                                      });
                                    }, hideCallBack: (value) {
                                      print('dv - ${value.toString()}');
                                      setState(() {
                                        cityData = value;
                                        selectCity = value.city_name;
                                        isCityHide = true;
                                        isSocityLoading = true;
                                        isSocityHide = true;
                                        socityData = null;
                                        selectSocity = (locale != null)
                                            ? locale.selectsocity2
                                            : 'Select Society/Area';
                                      });
                                      hitSocityList(
                                          cityData.city_name, locale, context);
                                    }, isError: isCityE, error: isCityT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    DropDownSocietyAddress(context,
                                        socityList: socityList,
                                        heading: 'Society/Area',
                                        hint: selectSocity,
                                        isHide: isSocityHide,
                                        isloading: isSocityLoading,
                                        callBackDrop: () {
                                      setState(() {
                                        isSocityHide = !isSocityHide;
                                      });
                                    }, hideCallBack: (value) {
                                      setState(() {
                                        socityData = value;
                                        selectSocity = value.society_name;
                                        isSocityHide = true;
                                      });
                                    }, isError: isSocietyE, error: isSocietyT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'Pincode',
                                        hint: 'Pincode',
                                        controller: pincodeC,
                                        inputType: TextInputType.number,
                                        isloading: isLoading,
                                        isError: isPinE,
                                        error: isPinT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'House/Flat Number',
                                        hint: 'Enter your house/flat number.',
                                        controller: houseNumberC,
                                        inputType: TextInputType.text,
                                        isloading: isLoading,
                                        isError: isHouseE,
                                        error: isHouseT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'State',
                                        hint: 'State',
                                        controller: stateC,
                                        inputType: TextInputType.text,
                                        isloading: isLoading,
                                        isError: isStateE,
                                        error: isStateT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'Address Line 1',
                                        hint: 'Address Line No.1',
                                        controller: addressLine1C,
                                        inputType: TextInputType.text,
                                        isloading: isLoading,
                                        isError: addresslineE,
                                        error: addresslineT),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                    AddressTitle(
                                        heading: 'Address Line 2',
                                        hint:
                                            'Address Line No. 2/LandMark (Optional)',
                                        controller: addressLine2C,
                                        inputType: TextInputType.text,
                                        isloading: isLoading),
                                    Divider(
                                      thickness: 2.5,
                                      color: Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Align(
                        widthFactor: 50,
                        heightFactor: 50,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      )),
          ],
        ),
      ),
    );
  }

  void addAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('${socityData.society_name}');
    var http = Client();
    http.post(addAddressUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'receiver_name': '${receiverNameC.text}',
      'receiver_phone': '${receiverPhoneC.text}',
      'city_name': '${cityData.city_name}',
      'society_name': '${socityData.society_name}',
      'house_no': '${houseNumberC.text}',
      'state': '${stateC.text}',
      'landmark': (addressLine2C.text != null &&
              addressLine2C.text.toString().length > 0)
          ? '${addressLine1C.text}${addressLine2C.text}'
          : '${addressLine1C.text}',
      'pin': '${pincodeC.text}',
      'lat': '${lat}',
      'lng': '${lng}',
      'type': '${addressType}',
    }).then((value) {
      print('addres - ${value.body}');
      if (value.statusCode == 200) {
        var jsData = jsonDecode(value.body);
        if (jsData['status'] == "1" || jsData['status'] == 1) {
          setState(() {
            currentAddress =
                '${houseNumberC.text}${addressLine1C.text}${socityData.society_name}${cityData.city_name}(${pincodeC.text})${stateC.text}';
            isVisbile = false;
            pincodeC.clear();
            stateC.clear();
            houseNumberC.clear();
            receiverNameC.clear();
            receiverPhoneC.clear();
            addressLine1C.clear();
            addressLine2C.clear();
            socityList.clear();
            socityData = null;
            selectSocity = 'Select your Society/Area';
          });
        }
        Toast.show(jsData['message'], context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isSavingAddress = false;
      });
    }).catchError((e) {
      setState(() {
        isSavingAddress = false;
      });
      print(e);
    });
  }

  void hitCityData(BuildContext context) {
    setState(() {
      isCityLoading = true;
    });
    var http = Client();
    http.get(cityUri).then((value) {
      if (value.statusCode == 200) {
        CityBeanModel data1 = CityBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            cityList.clear();
            cityList = List.from(data1.data);
            selectCity = cityList[0].city_name;
            cityData = cityList[0];
            socityList.clear();
            selectSocity = 'Select your socity/area';
            socityData = null;
          });
          if (cityList.length > 0) {
            setState(() {
              isSocityLoading = true;
            });
            hitSocityList(
                cityList[0].city_name, AppLocalizations.of(context), context);
          } else {
            selectCity = 'Select your city';
            cityData = null;
            setState(() {
              isCityLoading = false;
            });
          }
        } else {
          setState(() {
            selectCity = 'Select your city';
            cityData = null;
            isCityLoading = false;
          });
        }
      } else {
        setState(() {
          selectCity = 'Select your city';
          cityData = null;
          isCityLoading = false;
        });
      }
    }).catchError((e) {
      setState(() {
        selectCity = 'Select your city';
        cityData = null;
        isCityLoading = false;
      });
      print(e);
    });
  }

  void hitSocityList(dynamic cityName, locale, BuildContext context) {
    var http = Client();
    http.post(societyUri, body: {'city_name': '$cityName'}).then((value) {
      if (value.statusCode == 200) {
        StateBeanModel data1 = StateBeanModel.fromJson(jsonDecode(value.body));
        print('${data1.data.toString()}');
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            socityList.clear();
            socityList = List.from(data1.data);
            selectSocity = socityList[0].society_name;
            socityData = socityList[0];
          });
        } else {
          setState(() {
            selectSocity = (locale != null)
                ? locale.selectsocity2
                : 'Select your society/area';
            socityData = null;
          });
        }
      }
      setState(() {
        if (isCityLoading) {
          isCityLoading = false;
        }
        isSocityLoading = false;
      });
    }).catchError((e) {
      setState(() {
        selectSocity = (locale != null)
            ? locale.selectsocity2
            : 'Select your society/area';
        socityData = null;
        if (isCityLoading) {
          isCityLoading = false;
        }
        isSocityLoading = false;
      });
      print(e);
    });
  }
}

Widget AddressTitle(
    {String heading,
    String hint,
    TextEditingController controller,
    bool isloading = false,
    TextInputType inputType = TextInputType.text,
    bool isError = false,
    String error = '--'}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        TextFormField(
          readOnly: false,
          keyboardType: inputType,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
          ),
          // initialValue: '131001',
        ),
        SizedBox(
          height: 5,
        ),
        Visibility(
            visible: isError,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kRedColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: kWhiteColor, width: 1.5)),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_important,
                      color: kWhiteColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ],
                )))
      ],
    ),
  );
}

Widget DropDownCityAddress(BuildContext context,
    {String heading,
    String hint,
    bool isloading = false,
    bool isError = false,
    String error = '--',
    bool isOpen = false,
    Function callBackDrop,
    List<CityDataBean> cityList,
    void hideCallBack(CityDataBean cityList),
    bool isHide = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        Container(
            decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: kLightTextColor)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hint,
                  style: TextStyle(
                      fontSize: 16,
                      color: kMainTextColor,
                      fontWeight: FontWeight.w500),
                ),
                isloading
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : IconButton(
                        icon: isHide
                            ? Icon(Icons.arrow_drop_down_sharp)
                            : Icon(Icons.arrow_drop_up_sharp),
                        onPressed: () {
                          callBackDrop();
                        })
              ],
            )),
        Visibility(
          visible: (!isHide &&
              !isError &&
              !isloading &&
              (cityList != null && cityList.length > 0)),
          child: ListView.separated(
              itemCount: cityList.length,
              shrinkWrap: true,
              primary: false,
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1.5,
                  color: Colors.transparent,
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    hideCallBack(cityList[index]);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(color: kLightTextColor)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: Text(
                        cityList[index].city_name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w500),
                      )),
                );
              }),
        ),
        SizedBox(
          height: 5,
        ),
        Visibility(
            visible: isError,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kRedColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: kWhiteColor, width: 1.5)),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_important,
                      color: kWhiteColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ],
                )))
      ],
    ),
  );
}

Widget DropDownSocietyAddress(BuildContext context,
    {String heading,
    String hint,
    bool isloading = false,
    bool isError = false,
    String error = '--',
    bool isOpen = false,
    Function callBackDrop,
    List<StateDataBean> socityList,
    void hideCallBack(StateDataBean socityList),
    bool isHide = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        Container(
            decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: kLightTextColor)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                        fontSize: 16,
                        color: kMainTextColor,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                  ),
                ),
                isloading
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : IconButton(
                        icon: isHide
                            ? Icon(Icons.arrow_drop_down_sharp)
                            : Icon(Icons.arrow_drop_up_sharp),
                        onPressed: () {
                          callBackDrop();
                        })
              ],
            )),
        Visibility(
          visible: (!isHide &&
              !isError &&
              !isloading &&
              (socityList != null && socityList.length > 0)),
          child: ListView.separated(
              itemCount: socityList.length,
              shrinkWrap: true,
              primary: false,
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1.5,
                  color: Colors.transparent,
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    hideCallBack(socityList[index]);
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          border: Border.all(color: kLightTextColor)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: Text(
                        socityList[index].society_name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w500),
                      )),
                );
              }),
        ),
        SizedBox(
          height: 5,
        ),
        Visibility(
            visible: isError,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: kRedColor,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: kWhiteColor, width: 1.5)),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_important,
                      color: kWhiteColor,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ],
                )))
      ],
    ),
  );
}


Widget DropdownAType(BuildContext context,
    {String heading,
      String hint,
      Function callBackDrop,
      List<String> typeList,
      void hideCallBack(String type),
      bool isHide = true}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: TextStyle(
              fontSize: 18,
              color: kLightTextColor,
              fontWeight: FontWeight.w500),
        ),
        Container(
            decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(color: kLightTextColor)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            margin: EdgeInsets.only(top: 5),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hint,
                        style: TextStyle(
                            fontSize: 16,
                            color: kMainTextColor,
                            fontWeight: FontWeight.w500),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                        icon: isHide
                            ? Icon(Icons.arrow_drop_down_sharp)
                            : Icon(Icons.arrow_drop_up_sharp),
                        onPressed: () {
                          callBackDrop();
                        })
                  ],
                ),
                Visibility(
                  visible: !isHide,
                  child: Column(
                    children: [
                      ListView.separated(
                          itemCount: typeList.length,
                          shrinkWrap: true,
                          primary: false,
                          separatorBuilder: (context, index) {
                            return Divider(
                              thickness: 1.5,
                              color: Colors.transparent,
                            );
                          },
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                hideCallBack(typeList[index]);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: kWhiteColor,
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      border: Border.all(color: kLightTextColor)),
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  child: Text(
                                    typeList[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: kMainTextColor,
                                        fontWeight: FontWeight.w500),
                                  )),
                            );
                          }),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                )
              ],
            )
        ),
      ],
    ),
  );
}
