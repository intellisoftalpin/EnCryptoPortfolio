import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:crypto_offline/data/repository/ApiRepository/IApiRepository.dart';
import 'package:http/http.dart';

class ApiRepository implements IApiRepository {

  @override
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  @override
  Future<Response> checkConnection() async {
    final response = await get(
      Uri.parse(checkConnectionUrl),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return response;
  }

  @override
  Future<Response> coinsList() async {
    final response = await get(
      Uri.parse(coinsListUrl),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return response;
  }

  @override
  Future<Response> cardanoList() async {
    final response = await get(
      Uri.parse(coinsCardanoListUrl),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return response;
  }

  @override
  Future<Response> searchCoins(String search) async {
    final response = await get(
      Uri.parse(searchList + search),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return response;
  }

  @override
  Future<Response> coinById(String id)  async {
    final response = await get(
      Uri.parse(coinsListUrl + "/$id"),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return response;
  }


  static const String servUrl = "https://api.coinpaprika.com/v1";

  final String checkConnectionUrl = servUrl + "/ping";
  final String coinsListUrl = servUrl + "/tickers";
  final String searchList = servUrl + "/search?c=currencies&q=";

  final String currency = "/market_chart?vs_currency=usd&days=1&interval=hourly";  //coins/chainlink/market_chart?vs_currency=usd&days=1&interval=hourly
  final String price = "?tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false";

  // https://ctokens.io/api/v1/tokens/
  // https://ctokens.io/api/v1/tokens/images/29d222ce763455e3d7a09a665ce554f00ac89d2e99a1a83d267170c6.4d494e.png
  static const String servCardanoUrl = "https://ctokens.io/api/v1";
  final String coinsCardanoListUrl = servCardanoUrl + "/tokens/";

}
