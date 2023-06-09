import 'package:http/http.dart';

abstract class IApiRepository {

  Future<bool> check();
  Future<Response> checkConnection();
  Future<Response> coinsList();
  Future<Response> searchCoins(String search);
  Future<Response> coinById(String id);
  Future<Response> cardanoList();
}