
class PriceEntity  {
  late String date;
  late String? name;
  late String? symbol;
  late double? usdPrice;
  late double? eurPrice;
  late double? btcPrice;
  late double? ethPrice;
  late String? updated;
  late String coinId;
  late double? percentChange24h;
  late double? percentChange7d;
  late int? marketCap;
  late int? currencyId;

  PriceEntity({
    required this.date,
    this.name,
    this.symbol,
    this.usdPrice,
    this.eurPrice,
     this.btcPrice,
     this.ethPrice,
     this.updated,
    required this.coinId,
     this.percentChange24h,
     this.percentChange7d,
     this.marketCap,
     this.currencyId,
  });

  factory PriceEntity.fromDatabaseJson(Map<String, dynamic> data) => PriceEntity(
    date: data['date'],
    name: data['name'],
    symbol: data['symbol'],
    usdPrice: data['usdPrice'],
    eurPrice: data['eurPrice'],
    btcPrice: data['btcPrice'],
    ethPrice: data['ethPrice'],
    updated: data['updated'],
    coinId: data['coinId'],
    percentChange24h: data['percentChange24h'],
    percentChange7d: data['percentChange7d'],
    marketCap: data['marketCap'],
    currencyId: data['currencyId'],
  );

  Map<String, dynamic> toDatabaseJson() => {
    "date": this.date,
    "name": this.name,
    "symbol": this.symbol,
    "usdPrice": this.usdPrice,
    "eurPrice": this.eurPrice,
    "btcPrice": this.btcPrice,
    "ethPrice": this.ethPrice,
    "updated": this.updated,
    "coinId": this.coinId,
    "percentChange24h": this.percentChange24h,
    "percentChange7d": this.percentChange7d,
    "marketCap": this.marketCap,
    "currencyId": this.currencyId,
  };

  List<Object?> get props => [
    date,
    name,
    symbol,
    usdPrice,
    eurPrice,
    btcPrice,
    ethPrice,
    updated,
    coinId,
    percentChange24h,
    percentChange7d,
    marketCap,
    currencyId,
  ];

  @override
  String toString() {
    return '{date: $date, name: $name, symbol: $symbol, usdPrice: $usdPrice, eurPrice: $eurPrice, btcPrice: $btcPrice, ethPrice: $ethPrice, '
        'updated: $updated, coinId: $coinId, percentChange24h: $percentChange24h, percentChange7d: $percentChange7d,'
        'marketCap: $marketCap, currencyId: $currencyId }';
  }
}