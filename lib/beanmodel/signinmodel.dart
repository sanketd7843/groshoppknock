class SignInModel {
  dynamic status;
  dynamic message;
  SignInDataModel data;

  SignInModel(this.status, this.message, this.data);

  factory SignInModel.fromJson(dynamic json) {
    var data1 = json['data'];
    SignInDataModel dd;
    if(data1!=null){
       dd = SignInDataModel.fromJson(data1);
    }
    // SignInDataModel dd = SignInDataModel.fromJson(json['data']);

    return SignInModel(json['status'], json['message'], dd);
  }
}

class LoginModel {
  dynamic status;
  dynamic message;
  SignInDataModel data;

  LoginModel(this.status, this.message, this.data);

  factory LoginModel.fromJson(dynamic json) {
    // var data1 = json['data'] as List;
    // List<SignInDataModel> data3 = [];
    SignInDataModel dd = SignInDataModel.fromJson(json['data']);
    // if(data1!=null && data1.length>0){
    //   data3 =
    //   data1.map((e) => SignInDataModel.fromJson(e)).toList();
    //   dd = data3[0];
    // }

    return LoginModel(json['status'], json['message'], dd);
  }
}

class SignInDataModel {
  dynamic user_id;
  dynamic user_name;
  dynamic user_phone;
  dynamic user_email;
  dynamic device_id;
  dynamic user_image;
  dynamic user_city;
  dynamic user_area;
  dynamic user_password;
  dynamic otp_value;
  dynamic status;
  dynamic wallet;
  dynamic rewards;
  dynamic is_verified;
  dynamic block;
  dynamic reg_date;
  dynamic app_update;
  dynamic facebook_id;
  dynamic referral_code;

  SignInDataModel(
      this.user_id,
      this.user_name,
      this.user_phone,
      this.user_email,
      this.device_id,
      this.user_image,
      this.user_city,
      this.user_area,
      this.user_password,
      this.otp_value,
      this.status,
      this.wallet,
      this.rewards,
      this.is_verified,
      this.block,
      this.reg_date,
      this.app_update,
      this.facebook_id,
      this.referral_code);

  factory SignInDataModel.fromJson(dynamic json) {
    return SignInDataModel(
        json['user_id'],
        json['user_name'],
        json['user_phone'],
        json['user_email'],
        json['device_id'],
        json['user_image'],
        json['user_city'],
        json['user_area'],
        json['user_password'],
        json['otp_value'],
        json['status'],
        json['wallet'],
        json['rewards'],
        json['is_verified'],
        json['block'],
        json['reg_date'],
        json['app_update'],
        json['facebook_id'],
        json['referral_code']);
  }

  @override
  String toString() {
    return 'SignInDataModel{user_id: $user_id, user_name: $user_name, user_phone: $user_phone, user_email: $user_email, device_id: $device_id, user_image: $user_image, user_city: $user_city, user_area: $user_area, user_password: $user_password, otp_value: $otp_value, status: $status, wallet: $wallet, rewards: $rewards, is_verified: $is_verified, block: $block, reg_date: $reg_date, app_update: $app_update, facebook_id: $facebook_id, referral_code: $referral_code}';
  }
}
