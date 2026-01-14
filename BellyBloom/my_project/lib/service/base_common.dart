import 'package:my_project/model/user_account.dart';
import 'package:my_project/service/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseCommon {
  static final BaseCommon _instance = BaseCommon._internal();
  late SharedPreferences prefs;
  BaseCommon._internal();

  factory BaseCommon() {
    return _instance;
  }
  Future<void> initBaseCommon() async {
    prefs = await SharedPreferences.getInstance();
    userAccount = UserAccount(
      name: prefs.getString('name') ?? '',
      email: prefs.getString('email') ?? '',
      formCollection: null,
      uid: prefs.getString('uid') ?? '',
    );
  }

  UserAccount userAccount = UserAccount(
    name: '',
    email: '',
    formCollection: null,
    uid: '',
  );
  Future<void> saveUserAccount(UserAccount userAccount) async {
    this.userAccount = userAccount;
  }

  Future<void> saveAutoLogin({
    required String email,
    required String password,
  }) async {
    await prefs.setString('email', email);
    await prefs.setString('password', password);
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

  Future<void> clearUserAccount() async {
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('name');
    await prefs.remove('uid');
    userAccount = UserAccount(
      name: '',
      email: '',
      formCollection: null,
      uid: '',
    );
  }
}
