import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto_offline/app.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinBloc.dart';
import 'package:crypto_offline/bloc/SaveCoinBloc/SaveCoinState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_offline/view/ProfilePage/ProfilePage.dart';
import 'package:package_info/package_info.dart';

import '../../domain/entities/ListCoin.dart';
import 'ProfileTransactionsPage.dart';

class DetailsPage extends StatefulWidget {
  final CoinEntity coinEntity;
  final String coinPrice;

  DetailsPage(this.coinEntity, this.coinPrice);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late GlobalKey<ScaffoldState> _key;
  List<ListCoin> listCoinDb = [];

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    print('HEIGHT: ${ MediaQuery.of(context).size.height}');
    isScreenSmall = MediaQuery.of(context).size.height < 600 ? true : false;
    print('isScreenSmall: $isScreenSmall');
    _key = GlobalKey();
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      key: _key,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          LocaleKeys.details.tr(),
          style: kAppBarTextStyle(context, isScreenSmall),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: 35.0,
            color: Theme.of(context).focusColor,
          ),
          onPressed: () {
            _key.currentState!.openDrawer();
          },
        ),
      ),
      drawer: ProfilePageState.getDrawMenu(context, _packageInfo),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) =>
            orientation == Orientation.portrait ? portrait() : landscape(),
      ),
    );
  }

  Widget portrait() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).primaryColorDark,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(30.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 30.0,
                              backgroundColor: Colors.transparent,
                              child: CachedNetworkImage(
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                imageUrl: widget.coinEntity.image!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    FutureBuilder(
                                  future: checkContainImage(
                                      'assets/image/${widget.coinEntity.symbol.toLowerCase()}.png'),
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
                          SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                widget.coinEntity.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 30.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Text(
                        widget.coinPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  onPressed: () {
                    BlocListener<SaveCoinBloc, SaveCoinState>(
                        bloc: SaveCoinBloc(DatabaseProvider(),
                            HivePrefProfileRepositoryImpl(), widget.coinEntity),
                        listener: (context, state) {
                          if (state.state == SaveCoinStatus.save) {
                            BlocProvider.of<SaveCoinBloc>(context)
                                .add(SaveCoin(coin: widget.coinEntity));
                          }
                        });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileTransactionsPage(
                              id: widget.coinEntity.coinId,
                              symbol: widget.coinEntity.symbol,
                              isRelevant: 1,
                            )));
                  },
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    LocaleKeys.add.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumBodyTextSize),
                  ),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    LocaleKeys.cancel.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumBodyTextSize),
                  ),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget landscape() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, left: 20.0, bottom: 20.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // Colors.grey.shade700,
                      Theme.of(context).dividerColor,
                      Theme.of(context).primaryColorDark,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(30.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.transparent,
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              imageUrl: widget.coinEntity.image!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  FutureBuilder(
                                future: checkContainImage(
                                    'assets/image/${widget.coinEntity.symbol.toLowerCase()}.png'),
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
                          SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            child: Text(
                              widget.coinEntity.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 30.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        widget.coinPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 25.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  onPressed: () {
                    BlocListener<SaveCoinBloc, SaveCoinState>(
                        bloc: SaveCoinBloc(DatabaseProvider(),
                            HivePrefProfileRepositoryImpl(), widget.coinEntity),
                        listener: (context, state) {
                          if (state.state == SaveCoinStatus.save) {
                            BlocProvider.of<SaveCoinBloc>(context)
                                .add(SaveCoin(coin: widget.coinEntity));
                          }
                        });
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    LocaleKeys.add.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumBodyTextSize),
                  ),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  minWidth: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Text(
                    LocaleKeys.cancel.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumBodyTextSize),
                  ),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
