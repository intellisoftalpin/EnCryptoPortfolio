import 'package:crypto_offline/app.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  final String platform;
  final String image;
  const AboutPage({Key? key, required this.platform, required this.image}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('HEIGHT: ${ MediaQuery.of(context).size.height}');
    isScreenSmall = MediaQuery.of(context).size.height < 600 ? true : false;
    print('isScreenSmall: $isScreenSmall');
    final platform = widget.platform;
    final image = widget.image;
    String version = _packageInfo.version;
    int dots = version.replaceAll(new RegExp(r'[^\\.]'), '').length;
    if (dots == 3) {
      var pos = version.lastIndexOf('.');
      version = (pos != -1)? version.substring(0, pos): version;
      print('VERSION:: $version');
    }
    AssetImage background = AssetImage('assets/background/background.png');
    if(Theme.of(context).primaryColor == lBackgroundColor){
      background = AssetImage('assets/background/background_lt.png');
    }
    else if(Theme.of(context).primaryColor == kBackgroundColor){
      background = AssetImage('assets/background/background.png');
    }
    return WillPopScope(
        onWillPop: () async {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfilePage()));
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.about.tr(),
          style: kAppBarTextStyle(context, isScreenSmall),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 35.0,
            color: Theme.of(context).focusColor,
          ),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ProfilePage())),
        ),
        backgroundColor: Theme.of(context).splashColor,
        centerTitle: true,
        elevation: 0.0,
        bottomOpacity: 0.0,
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
      image: DecorationImage(
      image: background,
        fit: BoxFit.cover)),
        child: Center(
           child:OrientationBuilder(builder: (BuildContext context, Orientation orientation) =>
          orientation == Orientation.portrait ? portrait(image, platform, _packageInfo, version, context)
            : landscape(image, platform, _packageInfo, version, context),
    ),
        ),
      ),
    ));
  }
}

Widget portrait ( String image, String  platform, PackageInfo info, String version, BuildContext context) => Column(
  children: [
    SizedBox(
      height: 40.0,
    ),
    Container(
      width: 120.0,
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    ),
    SizedBox(
      height: 24.0,
    ),
    Expanded(
      flex: 4,
      child: Column(
        children: [
          Text(
            "EnCrypto",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 24.0,
            ),
          ),
          SizedBox(height: 8.0,),
          Text(
            "v. $version   build ${info.buildNumber}",
            style: TextStyle(
              color: Theme.of(context).focusColor,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    ),
    Expanded(
      flex: 6,
      child: Column(
        children: [
          SizedBox(
            height: 36.0,
          ),
          Text(
            LocaleKeys.platform.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 24.0,
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          SvgPicture.asset(image, width: 40.0,),
          SizedBox(
            height: 8.0,
          ),
          Text(platform),
        ],
      ),
    ),
    launchUrlAbout(),
],
);

Widget landscape (String image, String  platform, PackageInfo info, String version, BuildContext context) => Column(
  children: [
    SizedBox(
      height: 8.0,
    ),
    Container(
      width: 60.0,
      child: ClipOval(
        child: Image.asset(
          'assets/icons/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    ),
    SizedBox(
      height: 18.0,
    ),
    Expanded(
      flex: 4,
      child: Column(
        children: [
          Text(
            "EnCrypto",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 4.0,),
          Text(
            "v. $version    build ${info.buildNumber}",
            style: TextStyle(
              color: Theme.of(context).focusColor,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    ),
    Expanded(
      flex: 7,
      child: Column(
        children: [
          SizedBox(
            height: 14.0,
          ),
          Text(
            LocaleKeys.platform.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 18.0,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          SvgPicture.asset(image, width: 24.0,),
          SizedBox(
            height: 8.0,
          ),
          Text(platform),
        ],
      ),
    ),
    launchUrlAbout(),
  ],
);

Widget launchUrlAbout() =>
    Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 2.0),
        child: Center(
          child: new InkWell(
            onTap: _launchURL,
            child: new Text('encryptoportfolio.com',
                style: TextStyle(decoration: TextDecoration.underline,)),
          ),
        ),
      ),
    );

Future<void>  _launchURL() async {
   final urlAbout = 'https://encryptoportfolio.com/';
  // ignore: deprecated_member_use
  if (await canLaunch(urlAbout)) {
   // ignore: deprecated_member_use
   await launch(urlAbout, forceSafariVC: false);
  } else {
    throw 'Could not launch $urlAbout';
   }
  }
