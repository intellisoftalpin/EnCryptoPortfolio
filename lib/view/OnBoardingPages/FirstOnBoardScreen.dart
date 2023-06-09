import 'dart:io';

import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/OnBoardingPages/SecondOnBoardScreen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../app.dart';
import '../CreateProfilePage/CreateProfilePage.dart';

class FirstOnBoardScreen extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => FirstOnBoardScreen());
  }

  @override
  State<FirstOnBoardScreen> createState() => _FirstOnBoardScreenState();
}

class _FirstOnBoardScreenState extends State<FirstOnBoardScreen> {

  @override
  Widget build(BuildContext context) {
    print('HEIGHT: ${ MediaQuery.of(context).size.height}');
    isScreenSmall = MediaQuery.of(context).size.height < 600 ? true : false;
    print('isScreenSmall: $isScreenSmall');
    if (Platform.isAndroid) {
      const SystemUiOverlayStyle systemUiOverlayStyle =
          SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).toggleableActiveColor,
      appBar: null,
      body: Container(
        height: MediaQuery.of(context).size.height,
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                height: isScreenSmall ? MediaQuery.of(context).size.height * 0.4 : MediaQuery.of(context).size.height * 0.6,
                child: Stack(
                  children: [
                    Container(
                        margin: isScreenSmall ? EdgeInsets.only(top: 20) : EdgeInsets.only(top: 50),
                        alignment: Alignment.center,
                        height: isScreenSmall ? MediaQuery.of(context).size.height * 0.3 :
                        MediaQuery.of(context).size.height * 0.6,
                        child: SvgPicture.asset(
                          'assets/icons/first_onboard.svg',
                          alignment: Alignment.center,
                        )),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                            padding: EdgeInsets.only(top: 15.0),
                            height: 50.0,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                )),
                            child: Text(
                              LocaleKeys.small_intro.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22.0,
                                color: Theme.of(context).indicatorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ))),
                  ],
                )),
             Container(
                height: isScreenSmall ?  MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(children: [
                  Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
                      child: Text(LocaleKeys.onboard_first_text.tr(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: Theme.of(context).focusColor,
                                  fontFamily: 'MyriadPro',
                                  fontSize: 17.0))),
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/dollar_light.svg',
                                  alignment: Alignment.center,
                                  height: 20.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                SvgPicture.asset(
                                  'assets/icons/dollar_dark.svg',
                                  alignment: Alignment.center,
                                  height: 20.0,
                                )
                              ],
                            )),
                        Container(
                            margin: EdgeInsets.only(top: 5.0),
                            child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              color: Theme.of(context).secondaryHeaderColor,
                              child: MaterialButton(
                                minWidth: MediaQuery.of(context).size.width / 3,
                                padding:
                                    EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                                onPressed: () {
                                  box.write('onBoard', 1);
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SecondOnBoardScreen(
                                                  appBarBackArrow:
                                                      SizedBox.shrink())),
                                      (Route<dynamic> route) => false);
                                },
                                child: Text(
                                  LocaleKeys.next.tr(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          color: Theme.of(context).shadowColor,
                                          fontFamily: 'MyriadPro',
                                          fontSize: MediumBodyTextSize),
                                ),
                              ),
                            )),
                        Container(
                          height: 20.0,
                        )
                      ],
                    ),
                  )
                ]))
          ],
        ),
      ),
    );
  }
}
