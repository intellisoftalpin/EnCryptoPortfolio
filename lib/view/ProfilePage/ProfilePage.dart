import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/bloc/ProfileBloc/ProfileBloc.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/data/dbhive/ProfileModel.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/data/repository/SharedPrefProfile/SharedPrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/ListCoin.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:crypto_offline/view/AddCoinPage/AddCoinPage.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart';
import 'package:crypto_offline/view/ProfilePage/AboutPage.dart';
import 'package:crypto_offline/view/ProfilePage/InputPasswordPage.dart';
import 'package:crypto_offline/view/ProfilePage/PrivacyPolicyPage.dart';
import 'package:crypto_offline/view/ProfilePage/ProfileTransactionsPage.dart';
import 'package:crypto_offline/view/splash/splash.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import '../../app.dart';
import '../../bloc/CloseDbBloc/CloseDbBloc.dart';
import '../../utils/check_create_profile_time.dart';
import '../OnBoardingPages/SecondOnBoardScreen.dart';
import 'BackupRestorePage.dart';

//import 'EditProfilePage.dart';
import 'EditProfilePage.dart';
import 'SettingsPage.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
    as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
    as global;

class ProfilePage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => ProfilePage());
  }

  @override
  State<StatefulWidget> createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  SharedPreferences? preferences;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  late int walletBalanceWeight;
  List<ListCoin> listCoinDb = [];
  static List<ProfileModel> profile = [];
  List<CoinEntity> coinsList = [];
  List<double> wallet = [];
  List<TransactionEntity> transactionEntity = [];
  String id = '';
  static String url = "https://encryptoportfolio.com/privacy";
  static bool isCreateNewPortfolio = false;
  late DateTime currentBackPressTime;
  bool _isVisible = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  static String codes() {
    final languageFromPhoneSettings = ui.window.locale.toString();
    var systemAppLanguage = '';
    if (languageFromPhoneSettings.contains('ru')) {
      print("Russian");
      systemAppLanguage = 'ru';
    } else if (languageFromPhoneSettings.contains('en')) {
      print("English");
      systemAppLanguage = 'en';
    } else {
      print("Unknown");
      systemAppLanguage = 'en';
    }
    print("SystemLocale - $systemAppLanguage");
    return systemAppLanguage;
  }

  late GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> initializePreference() async {
    this.preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    print('HEIGHT: ${ MediaQuery.of(context).size.height}');
    isScreenSmall = MediaQuery.of(context).size.height < 600 ? true : false;
    print('isScreenSmall: $isScreenSmall');
    Stopwatch stopwatch = Stopwatch()..start();
    scaffoldKey = new GlobalKey<ScaffoldState>();
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print('ProfilePage  screenHeight = $screenHeight, screenWidth = $screenWidth');
    Widget header = getWalletBalance();
    return DoubleBack(
        message: LocaleKeys.double_back_exit.tr(),
        child: MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>(
                create: (context) => ProfileBloc(
                    DatabaseProvider(),
                    SharedPrefProfileRepositoryImpl(),
                    HivePrefProfileRepositoryImpl(),
                    ApiRepository()),
              ),
            ],
            child: BlocBuilder<ProfileBloc, ProfileState>(
                // buildWhen: (previous, current) => previous != current || previous.profile != current.profile,
                builder: (context, state) {
              switch (state.state) {
                case ProfileStatus.start:
                  print('start');
                  //  context.read<ProfileBloc>().add(CreateProfile());
                  return SplashPage();
                case ProfileStatus.loading:
                  print('loading');
                  profile = state.profile;
                  var error = (state.isErrorEmpty!) ? '' : LocaleKeys.incorrect_password_try_again.tr();
                  print(" loading profile = $profile , isErrorEmpty = ${state.isErrorEmpty} globals.pass = ${globals.pass}");
                  return InputPasswordPage(
                      globals.nameProfile,
                      global.idProfile,
                      ' ',
                      error,
                      profile);
                case ProfileStatus.load:
                  print('load');
                  profile = state.profile;
                  print(" load profile = $profile");
                  return SplashPage();
                case ProfileStatus.loaded:
                  print('loaded');
                  saveTemporaryPass();
                  profile = state.profile;
                  listCoinDb = state.listCoin!;
                  print(
                      " loaded profile = $profile, state.profile = ${state.profile}");
                  print("listCoinDb = $listCoinDb");
                  wallet = state.wallet!;
                  print("ProfilePage wallet = $wallet");
                  globals.profiles = profile;
                  String walletUsd = '';
                  wallet = (wallet.isEmpty) ? wallet = [0.0] : wallet;
                  walletUsd =
                      '\$ ${Decimal.convertPriceRound(wallet.first).toString()}';
                  if(walletUsd.length > 12){
                    header = getWalletBalanceColumn();
                  } else {
                    header = getWalletBalance();
                  }
                  print(
                      '!!!!::::TIME SPEND:::: ${stopwatch.elapsed.inMilliseconds}');
                  //SplashPage();
                  return Scaffold(
                    key: scaffoldKey,
                    backgroundColor: Theme.of(context).primaryColor,
                    appBar: AppBar(
                      elevation: 0.0,
                      backgroundColor: Theme.of(context).primaryColor,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              globals.nameProfile,
                              style: kAppBarTextStyle(context, isScreenSmall),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        listCoinDb.isEmpty
                            ? Visibility(
                                child: getIconAdd(),
                                visible: _isVisible,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                              )
                            : Visibility(
                                visible: !_isVisible,
                                child: getIconAdd(),
                              )
                      ],
                      leading: IconButton(
                        icon: Icon(
                          Icons.menu,
                          size: Theme.of(context)
                              .iconTheme
                              .copyWith(size: MediumIcon)
                              .size,
                          color: Theme.of(context).focusColor,
                        ),
                        onPressed: () => {
                          scaffoldKey.currentState!.openDrawer(),
                        },
                      ),
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        header,
                        (state.listCoin!.isEmpty)
                            ? Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddCoinPage()));
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        46.0)),
                                            backgroundColor: Theme.of(context)
                                                .secondaryHeaderColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 23, horizontal: 23)),
                                        child: new Icon(Icons.add,
                                            size: 45.0,
                                            color:
                                                Theme.of(context).shadowColor),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        LocaleKeys.press_add_coin.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .copyWith(
                                                fontSize: MediumPriceTextSize,
                                                color: Theme.of(context)
                                                    .hintColor),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: RefreshIndicator(
                                    onRefresh: () {
                                      return Future.delayed(
                                          Duration(seconds: 1), () {
                                        setState(() {
                                          context
                                              .read<ProfileBloc>()
                                              .add(CreateProfile());
                                          state.listCoin!;
                                          scaffoldKey.currentState;
                                        });
                                      });
                                    },
                                    child: ListView.builder(
                                        itemCount: state.listCoin!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return getListCoin(index, state);
                                        })),
                              ),
                      ],
                    ),
                    drawer: getDrawMenu(context, _packageInfo),
                  );
                case ProfileStatus.update:
                  return SplashPage();
              }
            })));
  }

  //Future<Null> refreshList() async {
  //  refreshKey.currentState?.activate();
  //  await Future.delayed(Duration(milliseconds: 100));
  //  setState(() {});
  //}

  static Widget getDrawMenu(BuildContext context, PackageInfo info) {
    // print(" getDrawMenu profile = $profile");
    String version = info.version;
    int dots = version.replaceAll(new RegExp(r'[^\\.]'), '').length;
    if (dots == 3) {
      var pos = version.lastIndexOf('.');
      version = (pos != -1) ? version.substring(0, pos) : version;
      print('VERSION:: $version');
    }
    return Drawer(
      elevation: 16.0,
      child: ListView(
        children: <Widget>[
          Container(
            height: 80.0,
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).canvasColor),
              accountName: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 35.0,
                    backgroundColor: Colors.transparent,
                    child: Image(
                      image: AssetImage('assets/icons/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "EnCrypto",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(width: 2.0),
                      Text(
                        "v. $version    build ${info.buildNumber}",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              accountEmail: null,
            ),
          ),
          Container(
            //  height: 120.0,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: profile.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            width: 1.0,
                            color: (profile[index].id == global.idProfile &&
                                    profile[index].nameProfile ==
                                        globals.nameProfile &&
                                    profile.length > 1)
                                ? Theme.of(context).secondaryHeaderColor
                                : Colors.transparent,
                          )),
                      child: ListTile(
                        title: new Text(
                          profile[index].nameProfile,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        leading: new Icon(Icons.perm_identity,
                            color: Theme.of(context).secondaryHeaderColor),
                        onTap: () {
                          String oldId = global.idProfile;
                          String id = profile[index].id;
                          String name = profile[index].nameProfile;
                          print(
                              "profile.elementAt(index) = ${profile[index].nameProfile} "
                              " profile.elementAt(index)Id = ${profile[index].id}");
                          if (id == global.idProfile &&
                              name == globals.nameProfile) {
                            Navigator.pop(context);
                          } else {
                            BlocProvider.of<CloseDbBloc>(context)
                                .add(UpdateProfile(idProfile: oldId));
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => InputPasswordPage(
                                    name, id, '', '', profile)));
                            print(
                                "profile.elementAt(index) = ${profile[index].nameProfile} "
                                " profile.elementAt(index)Id = ${profile[index].id}");
                            globals.nameProfile = name;
                            global.idProfile = id;
                          }
                        },
                      ));
                }),
          ),
          Divider(
              height: 0.4,
              color: Theme.of(context)
                  .cardTheme
                  .copyWith(color: Theme.of(context).hintColor)
                  .color),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: Theme.of(context).secondaryHeaderColor)),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                      onPressed: () {
                        isCreateNewPortfolio = true;
                        BlocProvider.of<CloseDbBloc>(context)
                            .add(UpdateProfile(idProfile: global.idProfile));
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => SecondOnBoardScreen(
                                        appBarBackArrow: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        size: 35.0,
                                        color: Theme.of(context).focusColor,
                                      ),
                                      onPressed: () => {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage()))
                                      },
                                    ))),
                            (Route<dynamic> route) => true);
                      },
                      child: Icon(
                        Icons.add,
                        size: Theme.of(context)
                            .iconTheme
                            .copyWith(size: MediumIcon)
                            .size,
                        color: Theme.of(context)
                            .iconTheme
                            .copyWith(color: Theme.of(context).shadowColor)
                            .color,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: Theme.of(context).secondaryHeaderColor)),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfilePage()));
                      },
                      child: Icon(
                        Icons.edit,
                        size: Theme.of(context)
                            .iconTheme
                            .copyWith(size: MediumIcon)
                            .size,
                        color: Theme.of(context)
                            .iconTheme
                            .copyWith(color: Theme.of(context).shadowColor)
                            .color,
                      ),
                      /*Image(
                        width: 22.0,
                          height: 22.0,
                          image: AssetImage('assets/icons/edit.png'),
                      ),*/
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
              height: 0.4,
              color: Theme.of(context)
                  .cardTheme
                  .copyWith(color: Theme.of(context).hintColor)
                  .color),
          Container(
            child: Column(
              children: [
                ListTile(
                  title: new Text(
                    LocaleKeys.settings.tr(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  leading: new Icon(Icons.settings,
                      color: Theme.of(context).secondaryHeaderColor),
                  onTap: () {
                    final systemAppLanguage = codes();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage(
                                  systemAppLanguage: systemAppLanguage,
                                )));
                  },
                ),
                ListTile(
                  title: new Text(
                    LocaleKeys.backup_restore.tr(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  leading: new Icon(Icons.refresh_rounded,
                      color: Theme.of(context).secondaryHeaderColor),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BackupRestorePage()));
                  },
                ),
                ListTile(
                  title: new Text(
                    LocaleKeys.privacy_policy.tr(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  leading: new Icon(Icons.lock_outlined,
                      color: Theme.of(context).secondaryHeaderColor),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage(url)));
                    /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage()));*/
                  },
                ),
                ListTile(
                  title: new Text(
                    LocaleKeys.about.tr(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  leading: new Icon(Icons.file_present,
                      color: Theme.of(context).secondaryHeaderColor),
                  onTap: () {
                    String platform = "Unknown";
                    String image = "";
                    if (Platform.isAndroid) {
                      if (Theme.of(context).primaryColor == lBackgroundColor) {
                        image = 'assets/icons/android_lt.svg';
                      } else if (Theme.of(context).primaryColor ==
                          kBackgroundColor) {
                        image = 'assets/icons/android.svg';
                      }
                      platform = "Android";
                    } else if (Platform.isIOS) {
                      if (Theme.of(context).primaryColor == lBackgroundColor) {
                        image = 'assets/icons/ios_lt.svg';
                      } else if (Theme.of(context).primaryColor ==
                          kBackgroundColor) {
                        image = 'assets/icons/ios.svg';
                      }
                      platform = "IOS";
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutPage(
                          platform: "$platform",
                          image: image,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(
              height: 0.4,
              color: Theme.of(context)
                  .cardTheme
                  .copyWith(color: Theme.of(context).hintColor)
                  .color),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor)),
                color: Theme.of(context).secondaryHeaderColor,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                  onPressed: () {
                    BlocProvider.of<CloseDbBloc>(context)
                        .add(UpdateProfile(idProfile: global.idProfile));
                    globals.passChosen = false;
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => InputPasswordPage(
                                globals.nameProfile,
                                global.idProfile,
                                '',
                                '',
                                profile)),
                        (Route<dynamic> route) => false);
                  },
                  child: Text(
                    LocaleKeys.lock_app_button.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumBodyTextSize),
                  ),
                  /*Image(
                        width: 22.0,
                          height: 22.0,
                          image: AssetImage('assets/icons/edit.png'),
                      ),*/
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getIconAdd() {
    return IconButton(
      icon: Icon(
        Icons.add,
        size: Theme.of(context).iconTheme.copyWith(size: MediumIcon).size,
        color: Theme.of(context).selectedRowColor,
      ),
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddCoinPage()));
      },
    );
  }

  Widget getWalletBalance() {
    String walletUsd = '';
    wallet = (wallet.isEmpty) ? wallet = [0.0] : wallet;
    walletUsd = Decimal.convertPriceRound(wallet.first).toString();
    walletUsd = wallet.first > 1.0 || wallet.first < -1 ? Decimal.dividePrice(walletUsd) : walletUsd;
    int menuItem = this.preferences?.getInt("menuPosition") ?? 1;
    String menuText = LocaleKeys.holdings.tr();
    Color check1 = Colors.transparent;
    Color check2 = Colors.transparent;
    Color check3 = Colors.transparent;
    Color check4 = Colors.transparent;
    Color check5 = Colors.transparent;
    if (menuItem == 1) {
      check1 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.holdings.tr();
    } else if (menuItem == 2) {
      check2 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.rank.tr();
    } else if (menuItem == 3) {
      check3 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.trend_up.tr();
    } else if (menuItem == 4) {
      check4 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.trend_down.tr();
    } else if (menuItem == 5) {
      check5 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.alphabet_sort.tr();
    }
    return Container(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).secondaryHeaderColor,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: Text(
                          LocaleKeys.wallet_balance.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontSize: MinTextSize,
                                  color: Theme.of(context).shadowColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 6.0, bottom: 6.0),
                        child: Text(
                          '\$ $walletUsd',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontSize: MediumTextSize,
                                  color: Theme.of(context).shadowColor),
                        ),
                      ),
                    ]),
              ),
            ),
            PopupMenuButton<int>(
                padding: EdgeInsets.all(0.0),
                color: Theme.of(context).unselectedWidgetColor,
                child: Container(
                  color: Theme.of(context).highlightColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          menuText,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontSize: LightTextSize,
                                  color: Theme.of(context).shadowColor),
                        ),
                      ),
                      Container(
                        width: 30.0,
                        height: 64.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_drop_down_outlined,
                              color: Theme.of(context).shadowColor),
                        ),
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 1);
                    });
                  }
                  if (value == 2) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 2);
                    });
                  }
                  if (value == 3) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 3);
                    });
                  }
                  if (value == 4) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 4);
                    });
                  }
                  if (value == 5) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 5);
                    });
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check1),
                            Text(LocaleKeys.holdings.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check2),
                            Text(LocaleKeys.rank.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 3,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check3),
                            Text(LocaleKeys.trend_up.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 4,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check4),
                            Text(LocaleKeys.trend_down.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 5,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check5),
                            Text(LocaleKeys.alphabet_sort.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                    ]),
          ],
        ),
      ),
    );
  }

  Widget getWalletBalanceColumn() {
    String walletUsd = '';
    wallet = (wallet.isEmpty) ? wallet = [0.0] : wallet;
    walletUsd = Decimal.convertPriceRound(wallet.first).toString();
    walletUsd = Decimal.dividePrice(walletUsd);
    int menuItem = this.preferences?.getInt("menuPosition") ?? 1;
    String menuText = LocaleKeys.holdings.tr();
    Color check1 = Colors.transparent;
    Color check2 = Colors.transparent;
    Color check3 = Colors.transparent;
    Color check4 = Colors.transparent;
    Color check5 = Colors.transparent;
    if (menuItem == 1) {
      check1 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.holdings.tr();
    } else if (menuItem == 2) {
      check2 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.rank.tr();
    } else if (menuItem == 3) {
      check3 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.trend_up.tr();
    } else if (menuItem == 4) {
      check4 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.trend_down.tr();
    } else if (menuItem == 5) {
      check5 = Theme.of(context).secondaryHeaderColor;
      menuText = LocaleKeys.alphabet_sort.tr();
    }
    return Container(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    topLeft: Radius.circular(5.0)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: Text(
                        LocaleKeys.wallet_balance.tr(),
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontSize: MinTextSize,
                            color: Theme.of(context).shadowColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, top: 6.0, bottom: 6.0),
                      child: Text(
                        '\$ $walletUsd',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontSize: MediumTextSize,
                            color: Theme.of(context).shadowColor),
                      ),
                    ),
                  ]),
            ),
            PopupMenuButton<int>(
                padding: EdgeInsets.all(0.0),
                color: Theme.of(context).unselectedWidgetColor,
                offset: Offset(10.0, 65.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5.0),
                        bottomRight: Radius.circular(5.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          menuText,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontSize: LightTextSize,
                                  color: Theme.of(context).shadowColor),
                        ),
                      ),
                      Container(
                        width: 30.0,
                        height: 64.0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_drop_down_outlined,
                              color: Theme.of(context).shadowColor),
                        ),
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 1);
                    });
                  }
                  if (value == 2) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 2);
                    });
                  }
                  if (value == 3) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 3);
                    });
                  }
                  if (value == 4) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 4);
                    });
                  }
                  if (value == 5) {
                    setState(() {
                      this.preferences?.setInt("menuPosition", 5);
                    });
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check1),
                            Text(LocaleKeys.holdings.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check2),
                            Text(LocaleKeys.rank.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 3,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check3),
                            Text(LocaleKeys.trend_up.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 4,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check4),
                            Text(LocaleKeys.trend_down.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 5,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check, color: check5),
                            Text(LocaleKeys.alphabet_sort.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                        fontSize: LightTextSize,
                                        color: Theme.of(context).shadowColor)),
                          ],
                        ),
                      ),
                    ]),
          ],
        ),
      ),
    );
  }

  Widget getListCoin(int index, ProfileState state) {
    print(" !!! isRelevant = ${state.listCoin![index].isRelevant}");
    String arrowImage = 'assets/image/arrow_up.png';
    String warningImage = 'assets/image/warning.png';
    Color arrowColor = kInIconColor;
    Color isNotRelevantColor = lTextSecondaryColor;
    Color isRelevantColor = Theme.of(context).secondaryHeaderColor;
    int menuItem = this.preferences?.getInt("menuPosition") ?? 1;
    if (menuItem == 1) {
      state.listCoin!.sort((a, b) => b.costUsd.compareTo(a.costUsd));
    } else if (menuItem == 2) {
      state.listCoin!.sort((b, a) => a.marketCap!.compareTo(b.marketCap!));
    } else if (menuItem == 3) {
      state.listCoin!
          .sort((a, b) => b.percentChange7d!.compareTo(a.percentChange7d!));
    } else if (menuItem == 4) {
      state.listCoin!
          .sort((a, b) => a.percentChange7d!.compareTo(b.percentChange7d!));
    } else if (menuItem == 5) {
      state.listCoin!
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    if (state.listCoin![index].percentChange7d! < 0) {
      arrowImage = 'assets/image/arrow_down.png';
      arrowColor = kOutIconColor;
    } else {
      arrowImage = 'assets/image/arrow_up.png';
      arrowColor = kInIconColor;
    }
    return state.listCoin![index].isRelevant == 1
        ? getCardListCoin(index, state, arrowImage, arrowColor, isRelevantColor)
        : Opacity(
            opacity: 0.6,
            child: getCardListCoin(
                index, state, warningImage, arrowColor, isNotRelevantColor));
  }

  Widget getCardListCoin(int index, ProfileState state, String arrowImage,
      Color arrowColor, Color color) {
    return Card(
      margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: InkWell(
        child: Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 30) / 6,
              height: 100.0,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 3, left: 4),
                    child: CircleAvatar(
                      radius: 19.0,
                      backgroundColor: Colors.transparent,
                      child: /*FutureBuilder(
                          future: checkContainImage(
                              'assets/image/${state.listCoin![index].symbol.toLowerCase()}.png'),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done)
                              return snapshot.data!;
                            else
                              return Image.asset('assets/image/place_holder.png');
                          },
                        ),*/
                          CachedNetworkImage(
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        imageUrl: '${state.listCoin![index].image}',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => FutureBuilder(
                          future: checkContainImage(
                              'assets/image/${state.listCoin![index].symbol.toLowerCase()}.png'),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done)
                              return snapshot.data!;
                            else
                              return Image.asset(
                                  'assets/image/place_holder.png');
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8.0, bottom: 6.0, top: 4.0),
                    child: Text(
                      "Cap.:\n\$${NumberFormat.compactCurrency(
                        locale: 'EN',
                        decimalDigits: 2,
                        symbol: '',
                      ).format(state.listCoin![index].marketCap)}",
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(fontSize: ProfileCoinSmallText),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 38.0,
                    margin: EdgeInsets.only(bottom: 1.0),
                    child: SizedBox(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 18.0, color: color),
                        Text(
                          "${state.listCoin![index].rank}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(fontSize: ProfileCoinSmallText),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            SizedBox(width: (MediaQuery.of(context).size.width - 30) / 30),
            Container(
              width: (MediaQuery.of(context).size.width - 30) / 1.65,
              height: 100.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 5.0, top: 5.0),
                    child: Text(
                      '${state.listCoin![index].name}',
                      style: Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(fontSize: ProfileCoinBigText),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width - 30) / 1.57,
                    margin: EdgeInsets.only(bottom: 10.0, top: 5.0),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            "${state.listCoin![index].quantity > 1 || state.listCoin![index].quantity < -1  ?
                            Decimal.dividePrice(Decimal.convertPriceRound(state.listCoin![index].quantity).toString()):
                            Decimal.convertPriceRound(state.listCoin![index].quantity).toString()} " +
                                " ${state.listCoin![index].symbol}",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(fontSize: PrivacyTextSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: color)),
                    color: color,
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: (MediaQuery.of(context).size.width - 30) / 33,
                          left: (MediaQuery.of(context).size.width - 30) / 66),
                      child: Text(
                        "${state.listCoin![index].costUsd > 1 || state.listCoin![index].costUsd < -1 ?
                        Decimal.dividePrice(Decimal.convertPriceRound(state.listCoin![index].costUsd).toString())
                            : Decimal.convertPriceRound(state.listCoin![index].costUsd).toString()}\$",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(fontSize: MediumPriceTextSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              width: (MediaQuery.of(context).size.width - 30) / 5.6,
              height: 95,
              child: Column(
                children: [
                  Text(
                    "\$${Decimal.dividePrice(Decimal.convertPriceRound(state.listCoin![index].price!).toString())}",
                    //state.coinsList![index].name,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontSize: ProfileCoinSmallText),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  SizedBox(height: 7.0),
                  arrowImage == 'assets/image/warning.png'
                      ? Image.asset(
                          arrowImage,
                          // color: arrowColor,
                          height: 45,
                          width:
                              (MediaQuery.of(context).size.width - 30) / 16.5,
                        )
                      : Image.asset(
                          arrowImage,
                          color: arrowColor,
                          height: 45,
                          width:
                              (MediaQuery.of(context).size.width - 30) / 16.5,
                        ),
                  SizedBox(height: 7.0),
                  Text(
                    "${state.listCoin![index].percentChange7d!.toStringAsFixed(2)}\% 7d",
                    //state.coinsList![index].name,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontSize: 11.0),
                  ),
                ],
              ),
              //IconButton(
              //  icon: const Icon(Icons.add),
              //  onPressed: () => {
              //    id = state.listCoin![index].coinId,
              //    print(id),
              //    Navigator.push(
              //        context,
              //        MaterialPageRoute(
              //            builder: (context) => TransactionsPage(
              //                symbol: state.listCoin![index].symbol,
              //                id: id,
              //                transactionId: -1))),
              //  },
              //),
            ),
          ],
        ),
        onTap: () => {
          id = state.listCoin![index].coinId,
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileTransactionsPage(
                        id: id,
                        symbol: state.listCoin![index].symbol,
                        isRelevant: state.listCoin![index].isRelevant,
                      ))),
        },
      ),
    );
  }

  saveTemporaryPass() {
    int pref = box.read(globals.nameProfile + global.idProfile) == null
        ? -1
        : box.read(globals.nameProfile + global.idProfile);
    if (pref == 0) {
      int? createDate =
          box.read('${globals.nameProfile + global.idProfile}create_time');
      int? enterDate =
          box.read('${globals.nameProfile + global.idProfile}enter_time');
      DateTime? profileCreateDate =
          DateTime.fromMillisecondsSinceEpoch(createDate!);
      DateTime? profileEnterDate =
          DateTime.fromMillisecondsSinceEpoch(enterDate!);
      if (createTimeCheck(profileCreateDate, profileEnterDate)) {
        box.write('${globals.nameProfile + global.idProfile}enter_time',
            DateTime.now().millisecondsSinceEpoch);
        box.write(
            '${globals.nameProfile + global.idProfile}pass', globals.pass);
        print('DONE!!!!!!!');
      }
    }
  }
}
