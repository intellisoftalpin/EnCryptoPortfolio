import 'package:crypto_offline/app.dart';
import 'package:crypto_offline/bloc/TransactionBloc/TransactionBloc.dart';
import 'package:crypto_offline/bloc/TransactionBloc/TransactionEvent.dart';
import 'package:crypto_offline/bloc/TransactionBloc/TransactionState.dart';
import 'package:crypto_offline/data/database/DbProvider.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepositoryImpl.dart';
import 'package:crypto_offline/data/dbhive/WalletModel.dart';
import 'package:crypto_offline/data/model/CurrentPrice.dart';
import 'package:crypto_offline/data/repository/ApiRepository/ApiRepository.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/generated/locale_keys.g.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/utils/decimal.dart';
import 'package:crypto_offline/view/splash/view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ProfileTransactionBloc/ProfileTransactionBloc.dart';
import 'ProfileTransactionsPage.dart';

class TransactionsPage extends StatefulWidget {
  final String symbol;
  final String id;
  final int transactionId;
  final int isRelevant;

  TransactionsPage(
      {required this.symbol,
        required this.id,
        required this.transactionId,
        required this.isRelevant});

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => TransactionsPage(
            symbol: '', id: '', transactionId: -1, isRelevant: 1));
  }

  @override
  _TransactionsPageState createState() =>
      _TransactionsPageState(symbol, id, transactionId, isRelevant);
}

class _TransactionsPageState extends State<TransactionsPage> {
  _TransactionsPageState(
      this.symbol, this.id, this.transactionId, this.isRelevant);

  String symbol;
  String id;
  int transactionId;
  int isRelevant;

  late double screenWidth;
  late double screenHeight;
  late Orientation orientation;

  DateTime selectedDate = DateTime.now();
  final List<String> _tType = [LocaleKeys.in_.tr(), LocaleKeys.out_.tr()];
  final List<String> _txDetailsIn = [
    LocaleKeys.buy_tr.tr(),
    LocaleKeys.transfer.tr(),
    LocaleKeys.exchange.tr(),
    LocaleKeys.mining.tr(),
    LocaleKeys.staking.tr()
  ];
  final List<String> _txDetailsOut = [
    LocaleKeys.sell.tr(),
    LocaleKeys.transfer.tr(),
    LocaleKeys.exchange.tr()
  ];
  FocusNode focusNode = FocusNode();
  TextEditingController cTrastWallet = TextEditingController();
  TextEditingController cType = TextEditingController();
  TextEditingController cTimestamp = TextEditingController();
  double cost = 0;
  String trastWallet = '';
  String txTrastWallet = '';
  String txType = '';
  List<String> _tDetails = [];
  String txDetails = '';
  String hitDetails = '';
  TextEditingController cDetails = TextEditingController();
  String timestamp = '';
  String details = LocaleKeys.buy.tr();
  String type = LocaleKeys.in_.tr();
  String _timestamp = '';
  double _cost = 0;
  bool isEdited = false;
  double _price = 0;
  double price = 0;
  String txPrice = '';
  String? wallet;

  List<TransactionEntity> transactionEntity = [];
  List<TransactionEntity> transactionById = [];
  List<CurrentPrice> coinPrice = [];
  List<double> walletCoin = [];
  List<WalletModel> listTrastWallet = [];
  var f = NumberFormat('##0.0##');

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    cTrastWallet.dispose();
    cType.dispose();
    cDetails.dispose();
    cTimestamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tDetails = _txDetailsIn;
    orientation = MediaQuery.of(context).orientation;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    print(" ::::::::: screenHeight :::: = $screenHeight");
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileTransactionsPage(
                    id: widget.id,
                    symbol: widget.symbol,
                    isRelevant: widget.isRelevant,
                  )));
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => TransactionsDetailsPage(
          //           id: id,
          //           symbol: symbol,
          //           isRelevant: isRelevant,
          //           transactionId: transactionId,
          //           cost: cost,
          //           type: type,
          //           details: details,
          //           timestamp: timestamp,
          //           price: price,
          //           trastWallet: trastWallet,
          //         )));
          return true;
        },
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TransactionBloc>(
              create: (context) => TransactionBloc(
                  DatabaseProvider(),
                  ApiRepository(),
                  HivePrefProfileRepositoryImpl(),
                  transactionById,
                  transactionEntity,
                  id,
                  walletCoin,
                  listTrastWallet,
                  transactionId),
            ),
            BlocProvider<ProfileTransactionBloc>(
              create: (context) => ProfileTransactionBloc(DatabaseProvider(),
                  ApiRepository(), walletCoin, [], id, transactionId),
            ),
          ],
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state.state == TransactionStatus.start) {
                context.read<TransactionBloc>().add(CoinTransaction(
                    id: id,
                    transactionId: transactionId,
                    transactionById: [],
                    walletCoin: [],
                    listTrastWallet: []));
                return SplashPage();
              } else if (state.state == TransactionStatus.get) {
                coinPrice = state.coinId!;
                price = coinPrice.first.usd!.toDouble();
                walletCoin = state.walletCoin!;
                listTrastWallet = state.listTrastWallet!;
                listTrastWallet[0] = WalletModel(
                    id: "clear",
                    name: LocaleKeys.wallet_clear_field.tr(),
                    walletType: "clear",
                    blockchains: "*",
                    link: "",
                    droid: "",
                    ios: "",
                    sort: "");
                print("listTrastWallet = $listTrastWallet");
                transactionById = state.transactionById!;
                print("transactionById1 = $transactionById");
                if (transactionById.isNotEmpty) {
                  type = transactionById.first.type;
                  details = transactionById.first.details;
                  cost = transactionById.first.qty;
                  trastWallet = transactionById.first.walletAddress!;
                }
                (transactionById.isNotEmpty)
                    ? price = transactionById.first.usdPrice!
                    : price = coinPrice.first.usd!.toDouble();
                (transactionById.isNotEmpty)
                    ? timestamp = transactionById.first.timestamp
                    : timestamp = "${selectedDate.toLocal()}".split(' ')[0];
              }
              return Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  appBar: AppBar(
                    elevation: 0.0,
                    backgroundColor: Theme.of(context).primaryColor,
                    centerTitle: true,
                    title: Text(
                      (transactionById.isNotEmpty)
                          ? LocaleKeys.edit_transaction.tr()
                          : LocaleKeys.add_transaction.tr(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontSize: isScreenSmall ? 20 : 23,
                        color: Theme.of(context).focusColor,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Myriad Pro',
                      ),
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
                      onPressed: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileTransactionsPage(
                                  id: widget.id,
                                  symbol: widget.symbol,
                                  isRelevant: widget.isRelevant,
                                )));
                      }
                    ),
                    actions: [
                      SizedBox(
                        height: 35.0,
                        width: 35.0,
                      )
                    ],
                  ),
                  body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: ListView(children: <Widget>[
                            getCost(),
                            Divider(
                              height: 0.4,
                              color: Theme.of(context)
                                  .cardTheme
                                  .copyWith(color: Theme.of(context).hintColor)
                                  .color,
                            ),
                            //getTxtype(),
                            // getTxdetails(),
                            getTxcost(),
                            // getTxtimestamp(),
                            // getCurrentPrice(),
                            getTrustWallet(),
                            // getAdvanced(),
                            // getButton(context),
                            getButton(context, cost.toString().replaceAll(",", ".")),
                          ]),
                        ),
                        //getButton(context, cost.replaceAll(",", ".")),
                      ]));
            },
          ),
        ));
  }

  Widget getCost() {
    walletCoin = (walletCoin.isEmpty) ? walletCoin = [0.0, 0.0] : walletCoin;
    String walletUsd = '';
    if (walletCoin.last > 1.0 || walletCoin.last < -1.0) {
      walletUsd = Decimal.convertPriceRound(walletCoin.last).toString();
      walletUsd = Decimal.dividePrice(walletUsd);
    } else {
      walletUsd = Decimal.convertPriceRound(walletCoin.last).toString();
    }
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 2.0),
                  child: Text(
                    '${walletCoin.first > 1.0 || walletCoin.first < -1.0 ? Decimal.dividePrice(Decimal.convertPriceRound(walletCoin.first).toString())
                      : Decimal.convertPriceRound(walletCoin.first).toString()}  $symbol',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontSize: MediumTextSize,
                        color: Theme.of(context).shadowColor),
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.only(left: 16.0, top: 6.0, bottom: 6.0),
                  child: Text(
                    '$walletUsd' + ' \$',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontSize: MediumTextSize,
                        color: Theme.of(context).shadowColor),
                  ),
                ),
              ]),
        ),
      ),
    );
  }

  Widget getTxtype() {
    (txType.isEmpty) ? cType.text = type : cType.text = txType;
    print("cType.text = ${cType.text}, type = $type");
    if (cType.text == 'In' || cType.text == 'Входящее') {
      cType.text = LocaleKeys.in_.tr();
      _tDetails = _txDetailsIn;
    } else if (cType.text == 'Out' || cType.text == 'Исходящее') {
      cType.text = LocaleKeys.out_.tr();
      _tDetails = _txDetailsOut;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Theme.of(context).cardColor,
              ),
              child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 2.0, 8.0, 2.0),
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: cType,
                      readOnly: true,
                      // keyboardType: TextInputType.name,
                      //  obscureText: false,
                      decoration:
                      kFieldNameEditProfileDecoration(context).copyWith(
                        fillColor: Theme.of(context).cardColor,
                        hintText: LocaleKeys.in_.tr(),
                      ),
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontFamily: 'MyriadPro',
                          color: Theme.of(context).primaryColorLight,
                          fontSize: MediumTextSize),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.enter_type.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Icon(Icons.keyboard_arrow_down_outlined,
                      size: Theme.of(context)
                          .iconTheme
                          .copyWith(size: MediumIcon)
                          .size!
                          .toDouble(),
                      color: Theme.of(context).iconTheme.color),
                ),
                SizedBox(
                  width: 5.0,
                )
              ]),
            ),
          ),
        ),
        PopupMenuButton<String>(
            offset: Offset(1, 0),
            icon: null,
            padding: EdgeInsets.all(0.0),
            color: Theme.of(context).iconTheme.color,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60.0,
            ),
            onSelected: (item) {
              txType = item.toString();
              cType.text = txType;
              print("txType select = $txType, cType = $cType");
              if (txType == LocaleKeys.in_.tr() ||
                  cType.text == LocaleKeys.in_.tr()) {
                _tDetails = _txDetailsIn;
                txDetails = LocaleKeys.buy.tr();
              } else if (txType == LocaleKeys.out_.tr() ||
                  cType.text == LocaleKeys.out_.tr()) {
                _tDetails = _txDetailsOut;
                txDetails = LocaleKeys.sell.tr();
              }
              cDetails.text = txDetails;
            },
            itemBuilder: (BuildContext context) {
              return _tType.map((item) {
                return PopupMenuItem(
                  value: item,
                  child: ListTile(
                    title: Text(
                      item,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).shadowColor,
                          fontFamily: 'MyriadPro',
                          fontSize: MediumTextSize),
                    ),
                  ),
                );
              }).toList();
            })
      ],
    );
  }

  Widget getTxdetails() {
    (txDetails.isEmpty) ? cDetails.text = details : cDetails.text = txDetails;
    if (cDetails.text == 'Buy') {
      cDetails.text = LocaleKeys.buy_tr.tr();
    } else if (cDetails.text == 'Transfer') {
      cDetails.text = LocaleKeys.transfer.tr();
    } else if (cDetails.text == 'Exchange') {
      cDetails.text = LocaleKeys.exchange.tr();
    } else if (cDetails.text == 'Mining') {
      cDetails.text = LocaleKeys.mining.tr();
    } else if (cDetails.text == 'Staking') {
      cDetails.text = LocaleKeys.staking.tr();
    }else if(cDetails.text == 'Sell'){
      cDetails.text = LocaleKeys.sell.tr();
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                color: Theme.of(context).cardColor,
              ),
              child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 2.0, 8.0, 2.0),
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: cDetails,
                      readOnly: true,
                      decoration:
                      kFieldNameEditProfileDecoration(context).copyWith(
                        fillColor: Theme.of(context).cardColor,
                        hintText: hitDetails,
                      ),
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontFamily: 'MyriadPro',
                          color: Theme.of(context).primaryColorLight,
                          fontSize: MediumTextSize),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.enter_details.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Icon(Icons.keyboard_arrow_down_outlined,
                      size: Theme.of(context)
                          .iconTheme
                          .copyWith(size: MediumIcon)
                          .size!
                          .toDouble(),
                      color: Theme.of(context).iconTheme.color),
                ),
                SizedBox(
                  width: 5.0,
                )
              ]),
            ),
          ),
        ),
        PopupMenuButton<String>(
          offset: Offset(1, -60),
          icon: null,
          padding: EdgeInsets.all(0.0),
          color: Theme.of(context).iconTheme.color,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
          ),
          onSelected: (item) {
            txDetails = item.toString();
            cDetails.text = txDetails;
          },
          itemBuilder: (BuildContext context) {
            return _tDetails.map((item) {
              return PopupMenuItem(
                value: item,
                child: ListTile(
                  title: Text(
                    item,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).shadowColor,
                        fontFamily: 'MyriadPro',
                        fontSize: MediumTextSize),
                  ),
                ),
              );
            }).toList();
          },
        )
      ],
    );
  }

  Widget getTxcost() {
    if(isEdited){
      cost = _cost;
    }else {
      _cost == 0.0 ? cost = cost : cost = _cost;
    }
    if (cost != 0) {
      cost = Decimal.convertPriceRound(double.parse(cost.toString()));
    }
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 6.0, 4.0, 6.0),
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    enableInteractiveSelection: true,
                    initialValue: transactionId == -1 ? '' : cost.toString(),
                    keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                    obscureText: false,
                    decoration: kFieldNameEditProfileDecoration(context)
                        .copyWith(
                        hintText: LocaleKeys.quantity.tr(),
                        fillColor: Theme.of(context).cardColor,
                        contentPadding:
                        EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                        errorStyle:
                        TextStyle(fontSize: 14.0, color: kErrorColor)),
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontFamily: 'MyriadPro',
                        color: Theme.of(context).primaryColorLight,
                        fontSize: MediumTextSize),
                    validator: (value) {
                      value = value.toString().replaceAll(",", ".");
                      if (value.isEmpty ||
                          double.tryParse(value) == null ||
                          double.tryParse(value)! < 0) {
                        return LocaleKeys.enter_quantity.tr();
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {
                      isEdited = true;
                      if (double.tryParse(value) != null) {
                        _cost = double.parse(value);
                      }
                      print(_cost);
                    }),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 2.0),
                  child: Text(
                    '$symbol',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontSize: MediumBodyTextSize,
                        color: Theme.of(context).indicatorColor),
                  ),
                ),
              ),
            ],
          ),
          getTxtype(),
          getTxdetails(),
          getTxtimestamp(),
          getCurrentPrice(),
        ],
      ),
    );
  }

  Widget getTxtimestamp() {
    (_timestamp.isEmpty)
        ? cTimestamp.text = timestamp
        : cTimestamp.text = _timestamp;
    cTimestamp.selection = TextSelection.fromPosition(
        TextPosition(offset: cTimestamp.text.length));
    return Padding(
      padding:
      const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 1.0, 8.0, 1.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                enableInteractiveSelection: true,
                controller: cTimestamp,
                decoration: kFieldNameEditProfileDecoration(context).copyWith(
                    fillColor: Theme.of(context).cardColor,
                    errorStyle: TextStyle(fontSize: 14.0, color: kErrorColor)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontFamily: 'MyriadPro',
                    color: Theme.of(context).primaryColorLight,
                    fontSize: MediumTextSize),
                validator: (value) {
                  if (DateTime.parse(value!).isAfter(DateTime.now())) {
                    return LocaleKeys.enter_correct_date.tr();
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _timestamp = value;
                  print(_timestamp);
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              iconSize: Theme.of(context)
                  .iconTheme
                  .copyWith(size: MediumIcon)
                  .size!
                  .toDouble(),
              color: Theme.of(context).iconTheme.color,
              onPressed: () => {
                _selectDate(context), // Refer step 3
              },
            ),
          ),
        ]),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      // Refer step 1
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColorLight,
              onPrimary: Theme.of(context).splashColor,
              surface: Theme.of(context).primaryColorDark,
              onSurface: Theme.of(context).selectedRowColor,
            ),
            dialogBackgroundColor: Theme.of(context).cardColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null)
      setState(() {
        selectedDate = picked.toLocal();
        _timestamp = "${selectedDate.toLocal()}".split(' ')[0];
        timestamp = _timestamp;
      });
  }

  Widget getCurrentPrice() {
    _price == 0.0 ? price = price : price = _price;
    price = Decimal.convertPriceRound(price);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 4.0, 6.0),
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              enableInteractiveSelection: true,
              initialValue: price.toString(),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              obscureText: false,
              decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  hintText: LocaleKeys.price.tr(),
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.fromLTRB(28.0, 0.0, 0.0, 0.0),
                  errorStyle: TextStyle(fontSize: 14.0, color: kErrorColor)),
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontFamily: 'MyriadPro',
                  color: Theme.of(context).primaryColorLight,
                  fontSize: MediumTextSize),
              validator: (value) {
                value = value.toString().replaceAll(",", ".");
                if (value.isEmpty ||
                    double.tryParse(value) == null ||
                    double.tryParse(value)! < 0) {
                  return LocaleKeys.enter_price.tr();
                }
                return null;
              },
              onChanged: (value) => setState(() {
                if (value.isEmpty) {
                  _price = 0.0;
                  txPrice = '';
                } else {
                  value = value.toString().replaceAll(",", ".");
                  print("double.tryParse(value) = ${double.tryParse(value)}");
                  if (double.tryParse(value) != null) {
                    txPrice = value;
                    print(
                        "TP value price = $value, _price = $_price, double.tryParse(value) = ${double.tryParse(value)}");
                  }
                }
                print(_price);
              }),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 2.0),
            child: Text(
             '\$',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: MediumBodyTextSize,
                  color: Theme.of(context).indicatorColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget getTrustWallet() {
    (wallet != null)
        ? cTrastWallet.text = wallet!
        : (txTrastWallet.isEmpty)
        ? cTrastWallet.text = trastWallet
        : cTrastWallet.text = txTrastWallet;
    cTrastWallet.selection = TextSelection.fromPosition(
        TextPosition(offset: cTrastWallet.text.length));
    return Padding(
      padding:
      const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 1.0, 8.0, 1.0),
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                controller: cTrastWallet,
                obscureText: false,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp("[0-9a-zA-Zа-яА-Я .-]")),
                ],
                decoration: kFieldNameEditProfileDecoration(context).copyWith(
                  fillColor: Theme.of(context).cardColor,
                  hintText: LocaleKeys.wallet_exchange.tr(),
                ),
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontFamily: 'MyriadPro',
                    color: Theme.of(context).primaryColorLight,
                    fontSize: MediumTextSize),
                onChanged: (value) => wallet = value,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(1.0),
              child: PopupMenuButton(
                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                iconSize: Theme.of(context)
                    .iconTheme
                    .copyWith(size: MediumIcon)
                    .size!
                    .toDouble(),
                color: Theme.of(context).iconTheme.color,
                itemBuilder: (BuildContext context) {
                  return listTrastWallet.map((item) {
                    return PopupMenuItem(
                      value: item.name,
                      child: ListTile(
                        title: Text(
                          item.name,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                              color: Theme.of(context).shadowColor,
                              fontFamily: 'MyriadPro',
                              fontSize: MediumTextSize),
                        ),
                      ),
                    );
                  }).toList();
                },
                onSelected: (item) {
                  setState(() {
                    txTrastWallet = item.toString();
                    if (txTrastWallet == LocaleKeys.wallet_clear_field.tr()) {
                      cTrastWallet.clear();
                      wallet = '';
                      FocusManager.instance.primaryFocus?.unfocus();
                      print('TextField cleared');
                    } else {
                      print(
                          "1 cTrastWallet.text = ${cTrastWallet.text},txTrastWallet = $txTrastWallet");
                      cTrastWallet.text = txTrastWallet;
                      wallet = txTrastWallet;
                      print(
                          "2 cTrastWallet.text = ${cTrastWallet.text},txTrastWallet = $txTrastWallet");
                    }
                  });
                },
              )),
        ]),
      ),
    );
  }

  Widget getAdvanced() {
    return Padding(
      padding:
      const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_right_outlined),
              iconSize: Theme.of(context)
                  .iconTheme
                  .copyWith(size: MediumIcon)
                  .size!
                  .toDouble(),
              color: Theme.of(context).iconTheme.color,
              onPressed: () {},
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
            child: Text(
              'Advanced',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                  fontSize: MediumBodyTextSize,
                  color: Theme.of(context).indicatorColor),
            ),
          ),
        ),
      ]),
    );
  }

  Widget getButton(BuildContext context, cost) {
    print("cost = $cost, price = $price, txPrice = $txPrice");
    (txPrice.trim().isNotEmpty) ? price = double.parse(txPrice) : price = price;
    print("price = $price, txPrice = $txPrice");
    double top = 0.0;
    screenHeight > 670.0 ? top = 32.0 : top = 12.0;
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, top, 8.0, 16.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32.0, 4.0, 8.0, 4.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileTransactionsPage(
                                id: widget.id,
                                symbol: widget.symbol,
                                isRelevant: widget.isRelevant,
                              )));
                      // Navigator.pushAndRemoveUntil(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => TransactionsDetailsPage(
                      //           id: id,
                      //           symbol: symbol,
                      //           isRelevant: isRelevant,
                      //           transactionId: transactionId,
                      //           cost: cost,
                      //           type: type,
                      //           details: details,
                      //           timestamp: timestamp,
                      //           price: price,
                      //           trastWallet: trastWallet,
                      //         )),
                      //         (Route<dynamic> route) => false);
                    },
                    child: Text(
                      LocaleKeys.cancel.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).shadowColor,
                          fontFamily: 'MyriadPro',
                          fontSize: LightTextSize),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 32.0, 4.0),
                child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(
                          color: Theme.of(context).secondaryHeaderColor)),
                  color: Theme.of(context).secondaryHeaderColor,
                  child: MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                    onPressed: () {
                      var now = new DateTime.now();
                      var formatter = new DateFormat('hh:mm');
                      String formattedDate = formatter.format(now);
                      print("formattedDate = $formattedDate");
                      if (_formKey.currentState!.validate()) {
                        if (transactionId != -1) {
                          transactionEntity = [
                            TransactionEntity(
                                transactionId: transactionId,
                                type: cType.text == LocaleKeys.in_.tr()
                                    ? 'In'
                                    : 'Out',
                                details: cDetails.text == LocaleKeys.buy_tr.tr()
                                    ? 'Buy'
                                    : cDetails.text == LocaleKeys.transfer.tr()
                                    ? 'Transfer'
                                    : cDetails.text ==
                                    LocaleKeys.exchange.tr()
                                    ? 'Exchange'
                                    : cDetails.text ==
                                    LocaleKeys.mining.tr()
                                    ? 'Mining'
                                    : cDetails.text ==
                                    LocaleKeys.staking.tr()
                                    ? 'Staking':
                                    cType.text == LocaleKeys.out_.tr()?
                                    'Sell' : 'Buy',
                                timestamp: cTimestamp.text,
                                lastActiveTime: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                qty: double.parse(cost),
                                usdPrice: price,
                                coinId: id,
                                walletAddress: (cTrastWallet.text.trim().isEmpty) ? '' :
                                cTrastWallet.text.trim()
                            )
                          ];
                        } else {
                          transactionEntity = [
                            TransactionEntity(
                                type: cType.text == LocaleKeys.in_.tr()
                                    ? 'In'
                                    : 'Out',
                                details: cDetails.text == LocaleKeys.buy_tr.tr()
                                    ? 'Buy'
                                    : cDetails.text == LocaleKeys.transfer.tr()
                                    ? 'Transfer'
                                    : cDetails.text ==
                                    LocaleKeys.exchange.tr()
                                    ? 'Exchange'
                                    : cDetails.text ==
                                    LocaleKeys.mining.tr()
                                    ? 'Mining'
                                    : cDetails.text ==
                                    LocaleKeys.staking.tr()
                                    ? 'Staking' :
                                    cType.text == LocaleKeys.out_.tr()?
                                    'Sell' : 'Buy',
                                timestamp: cTimestamp.text,
                                lastActiveTime: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                                qty: double.parse(cost),
                                usdPrice: price,
                                coinId: id,
                                walletAddress: (cTrastWallet.text.trim().isEmpty) ? ''
                                    : cTrastWallet.text.trim()
                            )
                          ];
                        }
                        print("transactionEntity = $transactionEntity");
                        context.read<TransactionBloc>().add(
                            SaveTransaction(transaction: transactionEntity));
                        Future.delayed(Duration(milliseconds: 200), (){
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileTransactionsPage(
                                    id: widget.id,
                                    symbol: widget.symbol,
                                    isRelevant: widget.isRelevant,
                                  )),
                                  (Route<dynamic> route) => false);
                        });
                      }
                    },
                    child: Text(
                      LocaleKeys.save.tr(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).shadowColor,
                          fontFamily: 'MyriadPro',
                          fontSize: LightTextSize),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
