import 'package:crypto_offline/bloc/TransactionDetailsBloc/TransactionDetailsState.dart';
import 'package:crypto_offline/utils/constants.dart';
import 'package:crypto_offline/view/ProfilePage/ProfileTransactionsPage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../bloc/ProfileTransactionBloc/ProfileTransactionBloc.dart';
import '../../bloc/ProfileTransactionBloc/ProfileTransactionEvent.dart';
import '../../bloc/TransactionDetailsBloc/TransactionDetailsBloc.dart';
import '../../data/database/DbProvider.dart';
import '../../data/repository/ApiRepository/ApiRepository.dart';
import '../../generated/locale_keys.g.dart';
import '../../utils/decimal.dart';
import 'TransactionsPage.dart';

class TransactionsDetailsPage extends StatefulWidget {
  final String id;
  final int transactionId;
  final int isRelevant;
  final String symbol;
  final String? cost;
  final String? type;
  final String? details;
  final String? timestamp;
  final double? price;
  final double? realPrice;
  final String? trastWallet;
  final double amountOfCoins; // amount of coins from all transactions
  final double commonPrice; // sum price from all transactions

  TransactionsDetailsPage(
      {required this.id,
        required this.symbol,
        required this.isRelevant,
        required this.transactionId,
        required this.cost,
        required this.type,
        required this.details,
        required this.timestamp,
        required this.price,
        required this.realPrice,
        required this.trastWallet,
        required this.amountOfCoins,
        required this.commonPrice});

  static Route route() {
    return MaterialPageRoute<void>(
        builder: (_) => TransactionsDetailsPage(
          id: '',
          symbol: '',
          isRelevant: 1,
          transactionId: 0,
          cost: '',
          type: '',
          details: '',
          timestamp: '',
          price: 0.0,
          realPrice: 0.0,
          trastWallet: '',
          amountOfCoins: 0.0,
          commonPrice: 0.0,
        ));
  }

  @override
  _TransactionsDetailsPageState createState() =>
      _TransactionsDetailsPageState();
}

class _TransactionsDetailsPageState extends State<TransactionsDetailsPage> {
  _TransactionsDetailsPageState();

  @override
  Widget build(BuildContext context) {
    print(
        'commonPrice: ${widget.commonPrice} amountOfCoins: ${widget.amountOfCoins}');
    double walletCoin = 0.0;
    double coinCost = 0.0;
    walletCoin = widget.commonPrice;
    coinCost = walletCoin / widget.amountOfCoins;
    String costUsd = '';
    costUsd = Decimal.convertPriceRound(coinCost).toString();
    costUsd = Decimal.dividePrice(costUsd);
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
        return true;
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileTransactionBloc>(
            create: (context) => ProfileTransactionBloc(DatabaseProvider(),
                ApiRepository(), [], [], widget.id, widget.transactionId),
          ),
          BlocProvider<TransactionDetailsBloc>(
              create: (context) => TransactionDetailsBloc(
                  DatabaseProvider(), widget.id, widget.transactionId)),
        ],
        child: BlocBuilder<TransactionDetailsBloc, TransactionDetailsState>(
          builder: (BuildContext context, state) {
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Theme.of(context).primaryColor,
                centerTitle: true,
                title: BlocBuilder<TransactionDetailsBloc,
                    TransactionDetailsState>(
                  builder: (BuildContext context, state) {
                    return Text(
                      '${state.transactionDetails?.type}',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Myriad Pro',
                        color: Theme.of(context).focusColor,
                      ),
                    );
                  },
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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileTransactionsPage(
                                id: widget.id,
                                symbol: widget.symbol,
                                isRelevant: widget.isRelevant,
                              )));
                    }),
                actions: [
                  SizedBox(
                    height: 35.0,
                    width: 35.0,
                  )
                ],
              ),
              body: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Theme.of(context).brightness == Brightness.dark &&
                            state.transactionDetails?.type == 'In'
                            ? SvgPicture.asset('assets/icons/incoming_dark.svg')
                            : Theme.of(context).brightness == Brightness.dark &&
                            state.transactionDetails?.type == 'Out'
                            ? SvgPicture.asset(
                            'assets/icons/outgoing_dark.svg')
                            : Theme.of(context).brightness ==
                            Brightness.light &&
                            state.transactionDetails?.type == 'In'
                            ? SvgPicture.asset(
                            'assets/icons/incoming_light.svg')
                            : SvgPicture.asset(
                            'assets/icons/outgoing_light.svg'),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              greyCard(state),
                              SizedBox(height: 20),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_1.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black
                                        : Theme.of(context)
                                        .secondaryHeaderColor),
                                title: Text(
                                    '${state.transactionDetails?.details}',
                                    style: TextStyle(fontFamily: 'Myriad Pro')),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_2.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black
                                        : Theme.of(context)
                                        .secondaryHeaderColor),
                                title: state.transactionDetails != null
                                    ? Text(
                                  '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty != 0 ? '- ' : ''}'
                                      '${state.transactionDetails!.qty == 0 ? '0.0' :
                                  state.transactionDetails!.qty > 1.0 ?
                                  Decimal.dividePrice(Decimal.convertPriceRound(state.transactionDetails!.qty).toString()) :
                                  Decimal.convertPriceRound(state.transactionDetails!.qty).toString()}',
                                  style:
                                  TextStyle(fontFamily: 'Myriad Pro'),
                                ): SizedBox.shrink(),
                                trailing: Text(
                                  '${widget.symbol}',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                ),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_3.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black
                                        : Theme.of(context)
                                        .secondaryHeaderColor),
                                title: state.transactionDetails != null
                                    ? Text(
                                    '${state.transactionDetails!.usdPrice == 0 ? '0.0' :
                                    state.transactionDetails!.usdPrice! > 1.0 ?
                                    Decimal.dividePrice(Decimal.convertPriceRound(state.transactionDetails!.usdPrice!).toString().trim()) :
                                    Decimal.convertPriceRound(state.transactionDetails!.usdPrice!).toString().trim()} \$',
                                    style:
                                    TextStyle(fontFamily: 'Myriad Pro'))
                                    : SizedBox.shrink(),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_4.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black
                                        : Theme.of(context)
                                        .secondaryHeaderColor),
                                title: Text(
                                    '${state.transactionDetails?.timestamp}',
                                    style: TextStyle(fontFamily: 'Myriad Pro')),
                                contentPadding: EdgeInsets.all(0),
                                minLeadingWidth: 30,
                                minVerticalPadding: 0,
                                dense: true,
                                visualDensity: VisualDensity(vertical: -3),
                              ),
                              state.transactionDetails?.walletAddress != '' &&
                                  state.transactionDetails?.walletAddress !=
                                      ' '
                                  ? ListTile(
                                leading: SvgPicture.asset(
                                    'assets/icons/img_5.svg',
                                    color: Theme.of(context).brightness ==
                                        Brightness.light
                                        ? Colors.black
                                        : Theme.of(context)
                                        .secondaryHeaderColor),
                                title: Text(
                                    '${state.transactionDetails?.walletAddress}',
                                    style: TextStyle(
                                        fontFamily: 'Myriad Pro')),
                                contentPadding: EdgeInsets.all(0),
                                minVerticalPadding: 0,
                                minLeadingWidth: 30,
                                dense: true,
                                visualDensity:
                                VisualDensity(vertical: -3),
                              )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    32.0, 4.0, 8.0, 4.0),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor)),
                                  color: Theme.of(context).secondaryHeaderColor,
                                  child: MaterialButton(
                                    minWidth: MediaQuery.of(context).size.width,
                                    padding:
                                    EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                    onPressed: () {
                                      BlocProvider.of<ProfileTransactionBloc>(
                                          context)
                                          .add(DeleteTransactionDetailsPage(
                                          transactionId:
                                          widget.transactionId));
                                      Future.delayed(
                                          const Duration(milliseconds: 200),
                                              () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileTransactionsPage(
                                                            id: widget.id,
                                                            symbol: widget.symbol,
                                                            isRelevant:
                                                            widget.isRelevant)),
                                                    (Route<dynamic> route) => false);
                                          });
                                    },
                                    child: Text(
                                      LocaleKeys.delete.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                          color:
                                          Theme.of(context).shadowColor,
                                          fontFamily: 'MyriadPro',
                                          fontSize: LightTextSize),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 4.0, 32.0, 4.0),
                                child: Material(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor)),
                                  color: Theme.of(context).secondaryHeaderColor,
                                  child: MaterialButton(
                                    minWidth: MediaQuery.of(context).size.width,
                                    padding:
                                    EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionsPage(
                                                      symbol: widget.symbol,
                                                      id: widget.id,
                                                      transactionId:
                                                      widget.transactionId,
                                                      isRelevant:
                                                      widget.isRelevant)));
                                    },
                                    child: Text(
                                      LocaleKeys.edit.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                          color:
                                          Theme.of(context).shadowColor,
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
                    ),
                  ]),
            );
          },
        ),
      ),
    );
  }

  Container greyCard(TransactionDetailsState state) {
    String num1 = '';
    String num2 = '';
    if (state.transactionDetails != null) {
      num1 = state.transactionDetails!.qty > 1.0
          ? Decimal.dividePrice(
          Decimal.convertPriceRound(state.transactionDetails!.qty)
              .toString()) :
      Decimal.convertPriceRound(state.transactionDetails!.qty).toString();
      num2 = ((state.transactionDetails!.qty *
          state.transactionDetails!.usdPrice!) >
          1.0)
          ? Decimal.dividePrice(Decimal.convertPriceRound(
          state.transactionDetails!.qty *
              state.transactionDetails!.usdPrice!)
          .toString())
          : Decimal.convertPriceRound(state.transactionDetails!.qty *
          state.transactionDetails!.usdPrice!)
          .toString();
    }
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              Text(
                '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty != 0 ? '- ' : ''}$num1 ${widget.symbol} /  ',
                style: TextStyle(
                  fontSize: 13.0,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '${state.transactionDetails?.type == 'Out' && state.transactionDetails!.qty *
                    state.transactionDetails!.usdPrice! != 0 ? '- ' : ''}$num2 \$',
                style: TextStyle(
                  fontSize: 13.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey
                  : Colors.transparent),
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.all(Radius.circular(8))),
    );
  }
}

