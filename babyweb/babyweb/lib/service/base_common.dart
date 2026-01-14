import 'package:babyweb/model/user_account.dart';
import 'package:babyweb/service/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseCommon {
  static final BaseCommon _instance = BaseCommon._internal();
  late SharedPreferences prefs;
  bool isLogin = false;

  // Constructor private
  BaseCommon._internal();

  // Factory constructor trả về instance duy nhất
  factory BaseCommon() {
    return _instance;
  }

  Future<void> initBaseCommon() async {
    prefs = await SharedPreferences.getInstance();

    userAccount = UserAccount(
      name: prefs.getString('name') ?? '',
      email: prefs.getString('email') ?? '',
      uid: prefs.getString('uid') ?? '',
    );
  }

  UserAccount userAccount = UserAccount(
    name: '',
    email: '',
    uid: '',
  );

  Future<void> saveUserAccount(UserAccount userAccount) async {
    this.userAccount = userAccount;
  }

  Future<void> saveAutoLogin({
    required String email,
    required String password,
  }) async {
    await prefs.setString('password', password);
    await prefs.setString('email', email);
    await prefs.setBool('isLogin', true);
  }

  Future<UserAccount?> checkLogin() async {
    try {
      String email = prefs.getString('email') ?? '';
      String password = prefs.getString('password') ?? '';
      if (prefs.getString('password') == null) {
        return null;
      }
      UserAccount userAccount = await AccountService.login(
        email: email,
        password: password,
      );
      return userAccount;
    } catch (e) {
      return null;
    }
  }
  Future<void> checkLoginTest() async {
    isLogin = prefs.getBool('isLogin') ?? false;
  }
}
