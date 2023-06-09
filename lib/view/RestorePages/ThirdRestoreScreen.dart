import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/hash_pass.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart'
as global;
import 'package:crypto_offline/view/RestorePages/FirstRestoreScreen.dart'
as recovery;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../../app.dart' as app;
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart'
as globals;

import '../../app.dart';
import '../../bloc/CloseDbBloc/CloseDbBloc.dart';
import '../../data/dbhive/ProfileModel.dart';

String nameProfile = '';
String pass = '';
bool passChosen = false;
final box = GetStorage('PassPrefer');
List<ProfileModel> profiles = [];

class ThirdRestoreScreen extends StatefulWidget {
  final Widget welcome;
  final int passPrefer;
  final bool passwordRemind;
  final bool passwordField;
  final bool confirmPasswordField;

  ThirdRestoreScreen({Key? key,
    required this.welcome,
    required this.passPrefer,
    required this.passwordRemind,
    required this.passwordField,
    required this.confirmPasswordField})
      : super(key: key);

  static Route route(BuildContext context) {
    return MaterialPageRoute<void>(
        builder: (_) =>
            ThirdRestoreScreen(
              welcome: Text(
                LocaleKeys.conf_pass.tr(),
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6!
                    .copyWith(
                    fontSize: LightTextSize,
                    color: Theme
                        .of(context)
                        .secondaryHeaderColor),
              ),
              passPrefer: 1,
              passwordRemind: true,
              confirmPasswordField: true,
              passwordField: true,
            ));
  }

  @override
  State<StatefulWidget> createState() {
    return ThirdRestoreScreenState();
  }
}

class ThirdRestoreScreenState extends State<ThirdRestoreScreen> {
  late double screenWidth;
  final nameController =
  TextEditingController(text: LocaleKeys.my_portfolio.tr());
  var passController = '';
  var passConfirmController = '';
  final _formKey = GlobalKey<FormState>();
  static List<ProfileModel> profile = [];

  //late Profile profile;
  List<String> profileList = [];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return WillPopScope(
        onWillPop: () async {
          app.recoveryPath = null;
          global.idProfile = recovery.lastProfileId!;
          ReceiveSharingIntent.reset();
          BlocProvider.of<CloseDbBloc>(this.context)
            ..add(UpdateProfile(idProfile: recovery.dbRecoveryName!));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => App()),
                  (Route<dynamic> route) => false);
          return true;
        },
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: false,
          onKey: (event) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              if (nameController.text.isNotEmpty) {
                _buttonEnter();
              }
            }
          },
          child: MultiBlocProvider(
            providers: [
              BlocProvider<CreateProfileBloc>(
                create: (context) =>
                    CreateProfileBloc(
                        DatabaseProvider(),
                        HivePrefProfileRepositoryImpl(),
                        '',
                        '',
                        null,
                        '',
                        0,
                        null),
              ),
            ],
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Theme
                    .of(context)
                    .dividerColor,
                appBar: AppBar(
                  centerTitle: true,
                  elevation: 0.0,
                  backgroundColor: Theme
                      .of(context)
                      .dividerColor,
                  title: Text(
                    LocaleKeys.create_portfolio.tr(),
                    style: TextStyle(
                      fontSize: MediumTextSize,
                      color: Theme
                          .of(context)
                          .indicatorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                body: LayoutBuilder(builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                      BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              profilePageLabel(),
                              namePasswordField(),
                              createButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })),
          ),
        ));
  }

  void _buttonEnter() {
    globals.nameProfile = nameController.text;
    global.idProfile = recovery.dbRecoveryName!;
    pass = '';
    print('CPP pass PREFER::::${widget.passPrefer}');
    if (widget.passPrefer == 0 || widget.passPrefer == 1) {
      pass = globals.pass;
    } else if (widget.passPrefer == 2 || widget.passPrefer == 3) {
      pass = hashPass(hashPassword).toString();
    }
    print("nameProfile = ${globals.nameProfile}, pass = $pass" +
        "_formKey.currentState = ${_formKey.currentState!.validate()}");
    print(
        'ID_PROF_THIRD_SCREEN:::: ${global
            .idProfile} NAME_PROF_THIRD_SCREEN:::: ${globals.nameProfile}');
    if (_formKey.currentState!.validate()) {
      app.recoveryPath = null;
      ReceiveSharingIntent.reset();
      BlocListener<CreateProfileBloc, CreateProfileState>(
          bloc: CreateProfileBloc(
              DatabaseProvider(),
              HivePrefProfileRepositoryImpl(),
              globals.nameProfile,
              global.idProfile,
              null,
              pass,
              widget.passPrefer,
              recovery.dbRecoveryName),
          listener: (context, state) {
            if (state.state == CreateProfileStatus.start) {
              BlocProvider.of<CreateProfileBloc>(context).add(SaveProfile(
                  profile: globals.nameProfile,
                  idProfile: global.idProfile,
                  pass: pass.trim(),
                  passPrefer: widget.passPrefer));
            }
          });
      box.write('onBoard', 2);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ProfilePage()),
              (Route<dynamic> route) => false);
    } else {
      globals.nameProfile = '';
      pass = '';
      passConfirmController = '';
    }
  }

  Widget profilePageLabel() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.welcome,
                SizedBox(
                  height: 5.0,
                ),
                Visibility(
                    child: Text(
                      LocaleKeys.pass_remind.tr(),
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline6!
                          .copyWith(
                          fontSize: MinTextSize,
                          color: Theme
                              .of(context)
                              .focusColor),
                    ),
                    visible: widget.passwordRemind),
              ],
            )),
      ),
    );
  }

  Widget namePasswordField() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: TextFormField(
              controller: nameController,
              obscureText: false,
              keyboardType: TextInputType.text,
              decoration: kFieldNameCreateProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.my_portfolio.tr(),
                  errorStyle: TextStyle(color: kErrorColor)),
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6!
                  .copyWith(
                  color: Theme
                      .of(context)
                      .disabledColor,
                  fontFamily: 'MyriadPro',
                  fontSize: MediumBodyTextSize),
              validator: (value) {
                if (value!.isEmpty || nameController.text.isEmpty) {
                  return LocaleKeys.enter_name.tr();
                }
                return null;
              },
              //onChanged: (value) => setState(() {
              //  nameController.text = value;
              //}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: Visibility(
              child: TextFormField(
                obscureText: true,
                autofocus: true,
                //controller: passController,
                keyboardType: TextInputType.text,
                decoration: kFieldPassCreateProfileDecoration(context).copyWith(
                    hintText: LocaleKeys.main_pass.tr(),
                    errorStyle: TextStyle(color: kErrorColor)),
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6!
                    .copyWith(
                    color: Theme
                        .of(context)
                        .disabledColor,
                    fontFamily: 'MyriadPro',
                    fontSize: MediumBodyTextSize),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.enter_password.tr();
                  }
                  return null;
                },
                onChanged: (value) =>
                    setState(() {
                      passController = value;
                    }),
              ),
              visible: widget.passwordField,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
            child: Visibility(
              child: TextFormField(
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: kFieldPassCreateProfileDecoration(context).copyWith(
                    hintText: LocaleKeys.confirm_password.tr(),
                    errorStyle: TextStyle(color: kErrorColor)),
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6!
                    .copyWith(
                    color: Theme
                        .of(context)
                        .disabledColor,
                    fontFamily: 'MyriadPro',
                    fontSize: MediumBodyTextSize),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.re_enter_password.tr();
                  }
                  print(passController);
                  print(passConfirmController);
                  if (passController != passConfirmController &&
                      passController.isNotEmpty) {
                    return LocaleKeys.password_not_match.tr();
                  }
                  return null;
                },
                onChanged: (value) =>
                    setState(() {
                      passConfirmController = value;
                    }),
              ),
              visible: widget.confirmPasswordField,
            ),
          ),
        ],
      ),
    );
  }

  Widget createButton() {
    globals.nameProfile = nameController.text;
    box.write('temporaryName', nameController.text);
    return Expanded(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
              child: Material(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(
                        color: Theme
                            .of(context)
                            .secondaryHeaderColor)),
                color: Theme
                    .of(context)
                    .secondaryHeaderColor,
                child: MaterialButton(
                  minWidth: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: EdgeInsets.fromLTRB(50.0, 8.0, 50.0, 8.0),
                  onPressed: () {
                      _buttonEnter();
                  },
                  child: Text(
                    LocaleKeys.create.tr(),
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline6!
                        .copyWith(
                        color: Theme
                            .of(context)
                            .shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumBodyTextSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, String description) {
    Widget gotIt = TextButton(
      child: Text(LocaleKeys.ok.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(description),
      actions: [
        gotIt,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
