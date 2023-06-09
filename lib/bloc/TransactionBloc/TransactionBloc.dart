
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto_offline/bloc/TransactionBloc/TransactionState.dart';
import 'package:crypto_offline/core/error/exeption.dart';
import 'package:crypto_offline/data/dbhive/HivePrefProfileRepository.dart';
import 'package:crypto_offline/data/dbhive/WalletModel.dart';
import 'package:crypto_offline/data/model/CoinModel.dart';
import 'package:crypto_offline/data/model/CurrentPrice.dart';
import 'package:crypto_offline/data/repository/ApiRepository/IApiRepository.dart';
import 'package:crypto_offline/data/repository/DbRepository/DbRepository.dart';
import 'package:crypto_offline/domain/entities/CoinEntity.dart';
import 'package:crypto_offline/domain/entities/PriceEntity.dart';
import 'package:crypto_offline/domain/entities/TransactionEntity.dart';
import 'package:crypto_offline/utils/file_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import '../../data/model/CardanoModel.dart';
import 'TransactionEvent.dart';
import 'package:crypto_offline/view/CreateProfilePage/CreateProfilePage.dart' as globals;
import 'package:crypto_offline/bloc/CreateProfile/CreateProfileBloc.dart' as global;


class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  List<TransactionEntity> transactionById;
  List<TransactionEntity> transaction;
  final DbRepository _dbRepository;
  final IApiRepository _apiRepository;
  final HivePrefProfileRepository _hiveProfileRepository;
  String id;
  List<double> walletCoin;
  List<WalletModel> listTrastWallet;
  int transactionId;


  TransactionBloc(this._dbRepository, this._apiRepository,
      this._hiveProfileRepository,
      this.transactionById, this.transaction, this.id, this.walletCoin,
      this.listTrastWallet,
      this.transactionId)
      : super(TransactionState(TransactionStatus.start)) {
    add(SaveTransaction(transaction: transaction));
    add(GetByTransactionId(transactionId: transactionId, transactionById: []));
    add(CoinTransaction(id: id,
        transactionId: transactionId,
        transactionById: [],
        walletCoin: [],
        listTrastWallet: []));
  }

  @override
  Stream<TransactionState> mapEventToState(TransactionEvent event) async* {
    if (event is CoinTransaction) {
      id = event.id;
      print("CoinTransaction id = $id");
      transactionId = event.transactionId;
      yield* _getCoinTx(event, state);
    } else if (event is SaveTransaction) {
      transaction = event.transaction;
      yield* _saveTransaction(event);
    }
  }

  Stream<TransactionState> _saveTransaction(TransactionEvent event) async* {
    try {
      await _dbRepository.openDb(global.idProfile, globals.pass);
      print("transaction save db = $transaction");
      if (transaction.isNotEmpty) {
        TransactionEntity transactionEntity = transaction.first;
        transactionId = transaction.first.transactionId ?? -1;
        print("transactionId update = $transactionId");
        if (transactionId == -1) {
            await _dbRepository.putTransaction(transactionEntity);
            print("transaction save db = $transactionEntity");
            List<TransactionEntity> list = await _dbRepository.getAllTransactionByIdCoin(id);
            print('listTransaction = $list');
        }else{
          await _dbRepository.updateTransaction(
              transactionEntity, transactionId);
          List<TransactionEntity> list = await _dbRepository.getTransaction(
              transactionId);
          print('transactionUpdate = $list');
        }
        var trastWallet = transaction.first.walletAddress;
        print('trastWallet::: $trastWallet');
        if (trastWallet!.isNotEmpty) {
          List<String> walletNames = [];
          for (var data in listTrastWallet) {
            walletNames.add(data.name);
          }
          if (walletNames.contains(trastWallet)){
            print('contained');
          } else {
            List<String> listName = [];
            listTrastWallet.forEach((element) {
              String list = element.name;
              listName.add(list);
            });

            if (!listName.contains(trastWallet)) {
              var id = trastWallet.toLowerCase().replaceAll(' ', '_').trim();
              if (id.length == 1) {
                id = '_' + id;
                trastWallet = trastWallet + ' ';
              }
              var wallet = WalletModel(id: id, name: trastWallet);
              print('wallet_to_save::: $wallet');
              await _hiveProfileRepository.saveWallet(wallet);
            }
          }
        }
      }
    } on Exception catch (e) {
      print("transaction e = $e");
      throw CacheExeption();
    }
  }

  Stream<TransactionState> _getCoinTx(TransactionEvent event, TransactionState state) async* {
    print('\n\n\n\n\n\n');
    print('-------------GET TRANSACTION-----------');
    print('\n\n\n\n\n\n');
    List<PriceEntity> priceById = [];
    List<CurrentPrice> coinPrice = [];
    List<PriceEntity> priceEntity = [];
    num priseUsd = 0;
    List<TransactionEntity> listTransaction;
    String formattedDate = await getDate();
    try {
      await _dbRepository.openDb(global.idProfile, globals.pass);

      listTrastWallet = await _hiveProfileRepository.showWallet();

      if (listTrastWallet.isEmpty) {
        var listWallet = await FileManager.readJson();
        print("listWallet readJson = $listWallet");
        await _hiveProfileRepository.saveWallets(listWallet);
        listTrastWallet = await _hiveProfileRepository.showWallet();
        print("listTrastWallet1 = $listTrastWallet");
      } else {
        listTrastWallet = listTrastWallet.where((e) => (e.name.length > 1)).toList();
      }
      print("listTrastWallet2 = $listTrastWallet");
      listTransaction = await _dbRepository.getAllTransactionByIdCoin(id);
      print('listTransaction = $listTransaction');

      print("id TB = $id");
      priceEntity = await getPriceEntity(formattedDate, id);
      priseUsd = priceEntity.first.usdPrice!;
      coinPrice = [CurrentPrice(usd: priceEntity.first.usdPrice)];
      priceById = [PriceEntity(date: formattedDate, coinId: id, usdPrice: priseUsd.toDouble())];

      if (transactionId != -1) {
        transactionById = await _dbRepository.getTransaction(transactionId);
        print("transactionById = $transactionById");
      } else {
        transactionById = [];
      }
      if (listTransaction.isNotEmpty) {
        walletCoin =
        await getWalletCoin(listTransaction, formattedDate, priceById);

        yield state.copyWith(
            TransactionStatus.get, transactionById, [], coinPrice, walletCoin,
            listTrastWallet);
      } else {
        yield state.copyWith(
            TransactionStatus.get, transactionById, [], coinPrice, [],
            listTrastWallet);
      }
    } on Exception catch (_) {
      coinPrice = [CurrentPrice(btc: 0, eth: 0, eur: 0, usd: 0)];
      yield state.copyWith(TransactionStatus.get, [], [], coinPrice);
      throw ServerExeption();
    }
  }

  Future <String> getDate() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    var timeformatter = new DateFormat('hh:mm');
    String formattedTime = timeformatter.format(now);
    String formattedDate = formatter.format(now);
    print("formattedDate = $formattedDate, formattedTime= $formattedTime");

    return formattedDate;
  }

  Future<List<PriceEntity>> getPriceEntity(String formattedDate, String id) async {
    List<PriceEntity> priceEntity = [];
    var internet = await _apiRepository.check();
    print("intenet = $internet");
    if (await FileManager.readCoinById(id) != null) {
      CoinEntity coinById = CoinEntity.fromDatabaseJson(
          await FileManager.readCoinById(id));
      print("TransactionBloc coinById = $coinById");
      priceEntity = [PriceEntity(
          date: formattedDate,
          coinId: coinById.coinId,
          usdPrice: coinById.price,
          name: coinById.name,
          symbol: coinById.symbol
      )
      ];
      print("priceEntity = $priceEntity");
    } else {
      if (internet) {
        Response response = await _apiRepository.coinById(id);
        if (response.statusCode == HttpStatus.ok) {
          var coinData = jsonDecode(response.body);
          print("coinData = $coinData");
          priceEntity = [];
          priceEntity = [PriceEntity(
              date: formattedDate,
              coinId: id,
              usdPrice: CoinModel
                  .fromJson(coinData)
                  .quotes!
                  .uSD!
                  .price!,
              name: CoinModel
                  .fromJson(coinData)
                  .name,
              symbol: CoinModel
                  .fromJson(coinData)
                  .symbol
          )
          ];
          print("priceEntity = $priceEntity");
        } else if((await _apiRepository.cardanoList()).statusCode == HttpStatus.ok) {
          Response responseCardano = await _apiRepository.cardanoList();
            Map data = jsonDecode(responseCardano.body);
            var cardanoList = (data["tokens"] as List).map((e) =>
                Tokens.fromJson(e)).cast<Tokens>().toList();
            for (var cardano in cardanoList) {
              if (cardano.tokenId == id) {
                priceEntity = [PriceEntity(
                    date: formattedDate,
                    coinId: cardano.tokenId!,
                    name: cardano.name!,
                    symbol: cardano.name!,
                    usdPrice: cardano.priceUsd!)
                ];
              } else {
                CoinEntity coin = await _dbRepository.getCoin(id);
                priceEntity = [PriceEntity(
                    date: formattedDate,
                    coinId: id,
                    name: coin.name,
                    symbol: coin.symbol,
                    usdPrice: coin.price)];
              }
            }
            print("priceEntity = $priceEntity");
        } else if((await _dbRepository.getCoin(id)).coinId.isNotEmpty) {
          CoinEntity coin = await _dbRepository.getCoin(id);
          priceEntity = [PriceEntity(
              date: formattedDate,
              coinId: id,
              name: coin.name,
              symbol: coin.symbol,
              usdPrice: coin.price)];
        }
      }
    }
    print("priceEntityHive = $priceEntity");
    return priceEntity;
  }

  Future<List<double>> getWalletCoin(List<TransactionEntity> transactions,
      String formattedDate, List<PriceEntity> priceEntity) async {
    double walletInOut = 0;
    List<double> walleted = [];
    var cost = 0.0;
    var priseUsd = 0.0;
    double costInOut = 0;
    print("priceEntity = $priceEntity");
    for (var element in transactions) {
      cost = element.qty;
      for (var price in priceEntity) {
        if (price.coinId == element.coinId) {priseUsd = price.usdPrice!;}
      }
      print("!!!!!!!!Transaction !usdPrice = $priseUsd");
      if (element.type == 'In') {
        walletInOut += cost * priseUsd;
        costInOut += cost;
      } else if (element.type == 'Out') {
        walletInOut -= cost * priseUsd;
        costInOut -= cost;
      }
      walleted.clear();
      walleted.insert(0, costInOut);
      walleted.insert(1, walletInOut);
      print("getWallet = $walleted");
    }
    return walleted;
  }
}