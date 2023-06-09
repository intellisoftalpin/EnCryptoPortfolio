
class CurrentPrice {
  CurrentPrice({
     this.btc,
     this.eth,
     this.eur,
     this.usd,

  });
  late final num? btc;
  late final num? eth;
  late final num? eur;
  late final num? usd;

  CurrentPrice.fromJson(Map<String, dynamic> json){
    btc = json['btc'];
    eth = json['eth'];
    eur = json['eur'];
    usd = json['usd'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['btc'] = btc;
    _data['eth'] = eth;
    _data['eur'] = eur;
    _data['usd'] = usd;
    return _data;
  }
  @override
  String toString() {
    return '{btc: $btc, eth: $eth, eur: $eur, usd: $usd,}';
  }
}