
class CoinModel{
  String? id;
  String? name;
  String? symbol;
  int? rank;
  Quotes? quotes;

  CoinModel(
      {this.id,
        this.name,
        this.symbol,
        this.rank,
        this.quotes,});

  CoinModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    symbol = json['symbol'];
    rank = json['rank'];
    quotes = json['quotes'] != null ? new Quotes.fromJson(json['quotes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['symbol'] = this.symbol;
    data['rank'] = this.rank;
    if (this.quotes != null) {
      data['quotes'] = this.quotes!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'rank': rank,
      'quotes': quotes!.toMap(),

    };
  }

  @override
  String toString() {
    return '{id: $id, name: $name, symbol: $symbol, rank: $rank, quotes: $quotes,}';
  }

}

class Quotes {
  USD? uSD;

  Quotes({this.uSD});

  Quotes.fromJson(Map<String, dynamic> json) {
    uSD = json['USD'] != null ? new USD.fromJson(json['USD']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.uSD != null) {
      data['USD'] = this.uSD!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'uSD': uSD,
    };
  }

  @override
  String toString() {
    return '{uSD: $uSD,}';
  }
}

class USD {
  double? price;
  double? percentChange24h;
  double? percentChange7d;
  int? marketCap;

  USD({this.price, this.percentChange24h, this.percentChange7d, this.marketCap});

  USD.fromJson(Map<String, dynamic> json) {
    price = (json['price'] / 1);
    percentChange24h = (json['percent_change_24h'] / 1);
    percentChange7d = (json['percent_change_7d'] / 1);
    marketCap = (json['market_cap']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    data['percent_change_24h'] = this.percentChange24h;
    data['percent_change_7d'] = this.percentChange7d;
    data['market_cap'] = this.marketCap;
    return data;
  }

  @override
  String toString() {
    return '{price: $price, percent_change_24h: $percentChange24h, '
        'percent_change_7d: $percentChange7d, market_cap: $marketCap}';
  }
}

