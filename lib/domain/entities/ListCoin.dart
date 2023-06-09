import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ListCoin extends Equatable{
  late String coinId;
  late String symbol;
  late String name;
  late String image;
  late double quantity;
  late double costUsd;
  late int? marketCap;
  late int? rank;
  late double? percentChange24h;
  late double? percentChange7d;
  late double? price;
  late int isRelevant;

  ListCoin({required this.coinId,
    required this.name,
    required this.symbol,
    required this.image,
    required this.quantity,
    required this.costUsd,
    required this.marketCap,
    required this.rank,
    required this.percentChange24h,
    required this.percentChange7d,
    required this.price,
    required this.isRelevant});

  factory ListCoin.fromDatabaseJson(Map<String, dynamic> data) =>
      ListCoin(
        coinId: data['coinId'],
        name: data['name'],
        symbol: data['symbol'],
        image: data['image'],
        quantity: data['quantity'],
        costUsd: data['costUsd'],
        marketCap: data['marketCap'],
        percentChange24h: data['percentChange24h'],
        percentChange7d: data['percentChange7d'],
        rank: data['rank'],
        price: data['price'],
          isRelevant: data['isRelevant'],
      );

  Map<String, dynamic> toDatabaseJson() =>
      {
        "coinId": this.coinId,
        "name": this.name,
        "symbol": this.symbol,
        "image": this.image,
        "quantity": this.quantity,
        "costUsd": this.costUsd,
        "marketCap": this.marketCap,
        "percentChange24h": this.percentChange24h,
        "percentChange7d": this.percentChange7d,
        "rank": this.rank,
        "price": this.price,
        "isRelevant": this.isRelevant
      };

  @override
  String toString() {
    return '{coinId: $coinId, percentChange24h: $percentChange24h, percentChange7d: $percentChange7d,'
        ' name: $name, marketCap: $marketCap, symbol: $symbol, image: $image, quantity: $quantity, '
        'costUsd: $costUsd, rank: $rank, price: $price, isRelevant: $isRelevant}';
  }

  List<Object?> get props =>
      [coinId, name, symbol, image, quantity, costUsd, marketCap, rank, price, isRelevant];
}