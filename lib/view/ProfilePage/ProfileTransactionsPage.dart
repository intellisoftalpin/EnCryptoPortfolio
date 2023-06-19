import 'package:crypto_offline/bloc/ProfileTransactionBloc/ProfileTransactionBloc.dart';
import 'package:crypto_offline/bloc/ProfileTransactionBloc/ProfileTransactionEvent.dart';
import 'package:crypto_offline/bloc/ProfileTransactionBloc/ProfileTransactionState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app.dart';
import '../../data/repository/ApiRepository/IApiRepository.dart';
import 'ProfilePage.dart';
import 'TransactionDetailsPage.dart';
import 'TransactionsPage.dart';

class ProfileTransactionsPage extends StatefulWidget {
  final String id;
  final String symbol;
  final int isRelevant;

  ProfileTransactionsPage(
      {required this.id, required this.symbol, required this.isRelevant});

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => ProfileTransactionsPage(
              id: '',
              symbol: '',
              isRelevant: 1,
            ));
  }

  @override
  _ProfileTransactionsPageState createState() =>
      _ProfileTransactionsPageState(id, symbol, isRelevant);
}

class _ProfileTransactionsPageState extends State<ProfileTransactionsPage> {
  _ProfileTransactionsPageState(this.id, this.symbol, this.isRelevant);

  String id;
  String symbol;
  int isRelevant;

  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;
  late GlobalKey<ScaffoldState> scaffoldKey;
  List<TransactionEntity> transactionList = [];
  List<double> walletCoin = [];
  String minus = '';
  int transactionId = -1;
  var d = NumberFormat('##0.0##');
  bool _isVisible = false;

  Future<bool> internet() async {
    IApiRepository _apiRepository = ApiRepository();
    bool internet = await _apiRepository.check();
    return internet;
  }

  @override
  Widget build(BuildContext context) {
    print('HEIGHT: ${MediaQuery.of(context).size.height}');
    isScreenSmall = MediaQuery.of(context).size.height < 600 ? true : false;
    print('isScreenSmall: $isScreenSmall');
    scaffoldKey = new GlobalKey<ScaffoldState>();
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileTransactionBloc>(
          create: (context) => ProfileTransactionBloc(DatabaseProvider(),
              ApiRepository(), walletCoin, transactionList, id, transactionId),
        ),
      ],
      child: BlocBuilder<ProfileTransactionBloc, ProfileTransactionState>(
        builder: (context, state) {
          if (state.state == ProfileTransactionStatus.start) {
            context.read<ProfileTransactionBloc>().add(CreateProfileTransaction(
                walletCoin: [], listTransaction: [], id: id));
            return SplashPage();
          } else if (state.state == ProfileTransactionStatus.get) {
            transactionList = state.transactionList!;
            walletCoin = state.walletCoin!;
          }
          return WillPopScope(
            onWillPop: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
              return true;
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Theme.of(context).primaryColor,
                title: state.transactionList!.length > 1
                    ? Text(LocaleKeys.transactions.tr() + " $symbol",
                        overflow: TextOverflow.fade,
                        style: kAppBarTextStyle(context, isScreenSmall))
                    : Text(
                        LocaleKeys.transaction.tr() + " $symbol",
                        overflow: TextOverflow.fade,
                        style: kAppBarTextStyle(context, isScreenSmall),
                      ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: Theme.of(context)
                        .iconTheme
                        .copyWith(size: MediumIcon)
                        .size,
                    color: Theme.of(context).focusColor,
                  ),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage())),
                ),
              ),
              floatingActionButton: state.transactionList!.isEmpty
                  ? Visibility(
                      visible: _isVisible, child: getFloatingActionButton())
                  : Visibility(
                      visible: !_isVisible, child: getFloatingActionButton()),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    getCost(),
                    Divider(
                      height: 0.4,
                      color: Theme.of(context)
                          .cardTheme
                          .copyWith(color: Theme.of(context).hintColor)
                          .color,
                    ),
                    FutureBuilder(
                      future: internet(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.hasData)
                          return (isRelevant == 0 && snapshot.data! == true)
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/image/warning.png',
                                        // color: arrowColor,
                                        height: 45,
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                    30) /
                                                16.5,
                                      ),
                                      Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(
                                                top: 16.0,
                                                left: 16.0,
                                                right: 16.0,
                                                bottom: 8),
                                            child: Center(
                                              child: Text(
                                                LocaleKeys.coin_is_relevant
                                                    .tr(),
                                                style: TextStyle(
                                                  fontSize: textSize14,
                                                  color: lErrorColorLight,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              : (isRelevant == 0 && snapshot.data! == false)
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/image/warning.png',
                                            // color: arrowColor,
                                            height: 45,
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    30) /
                                                16.5,
                                          ),
                                          Expanded(
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 16.0,
                                                    left: 16.0,
                                                    right: 16.0,
                                                    bottom: 8),
                                                child: Center(
                                                  child: Text(
                                                    LocaleKeys
                                                        .coin_is_relevant_internet
                                                        .tr(),
                                                    style: TextStyle(
                                                      fontSize: textSize14,
                                                      color: lErrorColorLight,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox.shrink();
                        else
                          return SizedBox.shrink();
                      },
                    ),
                    state.transactionList!.isEmpty
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
                                                  TransactionsPage(
                                                      symbol: symbol,
                                                      id: id,
                                                      transactionId: -1,
                                                      isRelevant: isRelevant)));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(46.0)),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 23, horizontal: 23)),
                                    child: new Icon(Icons.add,
                                        size: 45.0,
                                        color: Theme.of(context).shadowColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    LocaleKeys.press_add_transaction.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontSize: MediumPriceTextSize,
                                            color: Theme.of(context).hintColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: ListView.builder(
                                  itemCount: state.transactionList!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Dismissible(
                                      key: UniqueKey(),
                                      confirmDismiss:
                                          (DismissDirection direction) async {
                                        if (direction ==
                                            DismissDirection.startToEnd) {
                                          return await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                contentPadding: EdgeInsets.zero,
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20.0))),
                                                content: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0),
                                                  child: Container(
                                                      padding: EdgeInsets.only(
                                                          top: 10.0,
                                                          right: 10.0,
                                                          left: 10.0,
                                                          bottom: 5.0),
                                                      child: Text(
                                                        LocaleKeys
                                                            .confirm_delete
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6!
                                                            .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .hoverColor,
                                                                fontFamily:
                                                                    'MyriadPro',
                                                                fontSize: 14),
                                                      )),
                                                ),
                                                actions: <Widget>[
                                                  Center(
                                                      child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Divider(
                                                          height: 1.0,
                                                          color:
                                                              Theme.of(context)
                                                                  .hoverColor),
                                                      SizedBox(height: 10.0),
                                                      Container(
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true);
                                                              },
                                                              child: Container(
                                                                  width: 100.0,
                                                                  height: 25.0,
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .yes
                                                                        .tr(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: Theme.of(context).textTheme.headline6!.copyWith(
                                                                        color:
                                                                            kInIconColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'MyriadPro',
                                                                        fontSize:
                                                                            18),
                                                                  )),
                                                            ),
                                                            SizedBox(
                                                              width: 50.0,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false);
                                                              },
                                                              child: Container(
                                                                  width: 100.0,
                                                                  height: 25.0,
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .no
                                                                        .tr(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: Theme.of(context).textTheme.headline6!.copyWith(
                                                                        color:
                                                                            kErrorColorLight,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'MyriadPro',
                                                                        fontSize:
                                                                            18),
                                                                  )),
                                                            ),
                                                          ])),
                                                    ],
                                                  ))
                                                ],
                                              );
                                            },
                                          );
                                        } else if (direction ==
                                            DismissDirection.endToStart) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TransactionsPage(
                                                          symbol: symbol,
                                                          id: id,
                                                          transactionId: state
                                                              .transactionList![
                                                                  index]
                                                              .transactionId!,
                                                          isRelevant:
                                                              isRelevant)));
                                        }
                                        return null;
                                      },
                                      onDismissed: (direction) {
                                        BlocProvider.of<ProfileTransactionBloc>(
                                                context)
                                            .add(DeleteTransaction(
                                                transactionId: state
                                                    .transactionList![index]
                                                    .transactionId!));
                                        setState(() {});
                                      },
                                      background: Container(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: Theme.of(context)
                                                        .iconTheme
                                                        .copyWith(
                                                            size: MediumIcon)
                                                        .size,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  )),
                                              Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20.0),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: Theme.of(context)
                                                        .iconTheme
                                                        .copyWith(
                                                            size: MediumIcon)
                                                        .size,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  )),
                                            ],
                                          )),
                                      child: getListTransaction(
                                          index, state, context),
                                    );
                                  }),
                            ),
                          ),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget getCost() {
    String date = ' ';
    String time = ' ';
    List<String> dateTime = [];
    String wallet = '';
    String lastActive = '';
    if (transactionList.isNotEmpty) {
      dateTime = transactionList.last.timestamp.split(', ');
      date = dateTime.first;
      time = dateTime.last;
      lastActive = transactionList.last.lastActiveTime.split(', ').last;
    }
    print("date= $date, time= $time, dateTime= $dateTime");
    walletCoin =
        (walletCoin.isEmpty) ? walletCoin = [0.0, 0.0, 0.0] : walletCoin;
    if (walletCoin.last > 1.0 || walletCoin.last < -1.0) {
      wallet = Decimal.dividePrice(
          Decimal.convertPriceRound(walletCoin.last).toString());
    } else {
      wallet = Decimal.convertPriceRound(walletCoin.last).toString();
    }
    print(
        "walletCoin PTPage = $walletCoin, !!! ${Decimal.convertPriceRound(walletCoin.first).toString()}");
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context)
              .cardTheme
              .copyWith(color: Theme.of(context).secondaryHeaderColor)
              .color,
          child: Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: Text(
                          '${walletCoin.first > 1.0 || walletCoin.first < -1.0 ? Decimal.dividePrice(Decimal.convertPriceRound(walletCoin.first).toString()) : Decimal.convertPriceRound(walletCoin.first).toString()}' +
                              ' $symbol',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontSize: MediumTextSize,
                                  color: Theme.of(context).shadowColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, top: 4.0, bottom: 4.0),
                        child: Text(
                          //'${f.format(walletCoin.last)} '
                          wallet + ' \$',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            color: Theme.of(context).shadowColor,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      if (lastActive.isNotEmpty || lastActive != '')
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 4.0, bottom: 4.0),
                          child: Text(
                            lastActive,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    fontSize: LightTextSize,
                                    color: isRelevant == 1
                                        ? Color(0x93282B30)
                                        : lErrorColorLight),
                          ),
                        ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getListTransaction(
      int index, ProfileTransactionState state, BuildContext context) {
    Widget icon = Text('');
    Widget iconTr = Icon(Icons.height);
    String usdPrice = '';
    double currentPrice = 0.0;
    double customCurrentPrice = 0.0;
    double realPrice = 0.0;
    bool visible = false;
    print('USD:::${state.transactionList![index].usdPrice!}');
    String qty =
        Decimal.convertPriceRound(state.transactionList![index].qty).toString();
    if (state.transactionList![index].usdPrice! < 1.0) {
      usdPrice =
          Decimal.convertPriceRound(state.transactionList![index].usdPrice!)
              .toString();
    } else {
      usdPrice = Decimal.dividePrice(
          Decimal.convertPriceRound(state.transactionList![index].usdPrice!)
              .toString());
    }
    currentPrice = Decimal.convertPriceRound(
        walletCoin[1] * state.transactionList![index].qty);
    customCurrentPrice = Decimal.convertPriceRound(
        state.transactionList![index].usdPrice! *
            state.transactionList![index].qty);
    realPrice = Decimal.convertPriceRound(walletCoin[1]);
    print(
        " currentPrice = $currentPrice, state.transactionList![index].walletAddress = ${state.transactionList![index].walletAddress}");
    visible = (state.transactionList![index].walletAddress!.isEmpty ||
            state.transactionList![index].walletAddress == ' ')
        ? false
        : true;
    if (state.transactionList![index].type == 'In') {
      minus = '';
      if (state.transactionList![index].qty == 0) {
        iconTr = SvgPicture.asset(
          'assets/icons/bidirectional_arrow.svg',
          height: 30,
          color: Theme.of(context)
              .cardTheme
              .copyWith(color: Theme.of(context).secondaryHeaderColor)
              .color,
        );
      } else {
        iconTr = Icon(
          Icons.arrow_upward_outlined,
          color:
              Theme.of(context).iconTheme.copyWith(color: kInIconColor).color,
        );
      }
      icon = Text(
        'In',
        style: Theme.of(context).textTheme.headline6!.copyWith(
            fontSize: MinTextSize,
            color: Theme.of(context).unselectedWidgetColor),
      );
    } else if (state.transactionList![index].type == 'Out') {
      if (currentPrice == 0.0) {
        minus = '';
      } else {
        minus = '-';
      }
      if (state.transactionList![index].qty == 0) {
        iconTr = SvgPicture.asset(
          'assets/icons/bidirectional_arrow.svg',
          height: 30,
          color: Theme.of(context)
              .cardTheme
              .copyWith(color: Theme.of(context).secondaryHeaderColor)
              .color,
        );
      } else {
        iconTr = Icon(
          Icons.arrow_downward_outlined,
          color:
              Theme.of(context).iconTheme.copyWith(color: kOutIconColor).color,
        );
      }
      icon = Text(
        'Out',
        style: Theme.of(context).textTheme.headline6!.copyWith(
            fontSize: MinTextSize,
            color: Theme.of(context).unselectedWidgetColor),
      );
    } else if (state.transactionList![index].type == 'Wallet') {
      iconTr = Icon(Icons.height);
      icon = Text(
        'Auto',
        style: Theme.of(context).textTheme.headline6!.copyWith(
            fontSize: MinTextSize,
            color: Theme.of(context).unselectedWidgetColor),
      );
    }
    String sumUsd = '';
    String usd = '';

    if (realPrice !=
        Decimal.convertPriceRound(state.transactionList![index].usdPrice!)) {
      usd =
          '${realPrice > 1.0 ? Decimal.dividePrice(realPrice.toString()) : realPrice} ($usdPrice) \$';
      sumUsd =
          '$minus ${(walletCoin[1] * state.transactionList![index].qty > 1.0) ? Decimal.dividePrice(currentPrice.toString()) : currentPrice.toString()} (${customCurrentPrice > 1.0 ? Decimal.dividePrice(customCurrentPrice.toString()) : customCurrentPrice}) \$';
    } else {
      usd = '$usdPrice \$';
      sumUsd =
          '$minus ${(walletCoin[1] * state.transactionList![index].qty > 1.0) ? Decimal.dividePrice(currentPrice.toString()) : currentPrice.toString()} \$';
    }
    return Row(
      children: [
        Expanded(
          child: Card(
            margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: ListTile(
              title: Text(
                '$minus${state.transactionList![index].qty > 1.0 ? Decimal.dividePrice(qty) : qty} $symbol',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: MediumTextSize),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 3.0, right: 8.0, left: 8.0),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(
                              color: Theme.of(context).secondaryHeaderColor)),
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 1.0, bottom: 1.0, right: 2.0, left: 2.0),
                        child: Text(
                          "$sumUsd",
                          //state.coinsList![index].name,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            color: Theme.of(context).shadowColor,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 1.0, bottom: 1.0, right: 6.0, left: 8.0),
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .secondaryHeaderColor)),
                            color: Theme.of(context).secondaryHeaderColor,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 1.0, bottom: 1.0, right: 2.0, left: 2.0),
                              child: Text(
                                "$usd",
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                //state.coinsList![index].name,
                                style: TextStyle(
                                  color: Theme.of(context).shadowColor,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 1.0, bottom: 1.0, left: 10.0),
                          child: Text(
                            "${state.transactionList![index].timestamp}",
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                            //state.coinsList![index].name,
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    fontSize: ProfileCoinSmallText,
                                    color: isRelevant == 1
                                        ? Theme.of(context).hintColor
                                        : lErrorColorLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: visible,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 2.0, bottom: 2.0, left: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "Wallet: ",
                            //state.coinsList![index].name,
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(fontSize: ProfileCoinSmallText),
                          ),
                          Expanded(
                            child: Text(
                              "${state.transactionList![index].walletAddress}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              //state.coinsList![index].name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(fontSize: ProfileCoinSmallText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    child: icon,
                    backgroundColor: Theme.of(context)
                        .cardTheme
                        .copyWith(color: Theme.of(context).hoverColor)
                        .color,
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  iconTr,
                ],
              ),
              onTap: () => {
                print(
                    "state.transactionList![index].transactionId! = ${state.transactionList![index].transactionId!}"),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TransactionsDetailsPage(
                              id: id,
                              symbol: symbol,
                              isRelevant: isRelevant,
                              transactionId:
                                  state.transactionList![index].transactionId!,
                              cost:
                                  state.transactionList![index].qty.toString(),
                              type: state.transactionList![index].type,
                              details: state.transactionList![index].details,
                              timestamp:
                                  state.transactionList![index].timestamp,
                              price: state.transactionList![index].usdPrice!,
                              realPrice:
                                  Decimal.convertPriceRound(walletCoin[1]),
                              trastWallet:
                                  state.transactionList![index].walletAddress!,
                              // commonPrice: currentPrice,
                              // commonPrice: walletCoin[1],
                              amountOfCoins: walletCoin.first,
                              commonPrice: walletCoin.last,
                            ))),
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget getFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
          child: FloatingActionButton(
            elevation: SettingsCardRadius,
            hoverElevation: BigTextSize,
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            child: new Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionsPage(
                          symbol: symbol,
                          id: id,
                          transactionId: -1,
                          isRelevant: isRelevant)));
            },
          ),
        ),
      ],
    );
  }
}
