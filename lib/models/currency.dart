class CurrencyModel {
  final int currencyId;
  final String currencyCode;
  final String currencyName;
  final String symbol;
  final double exchangeRateToBase;

  const CurrencyModel({
    required this.currencyId,
    required this.currencyCode,
    required this.currencyName,
    required this.symbol,
    required this.exchangeRateToBase,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
        currencyId: json['currencyId'] as int? ?? 0,
        currencyCode: json['currencyCode'] as String? ?? '',
        currencyName: json['currencyName'] as String? ?? '',
        symbol: json['symbol'] as String? ?? '',
        exchangeRateToBase:
            (json['exchangeRateToBase'] as num?)?.toDouble() ?? 1.0,
      );

  Map<String, dynamic> toJson() => {
        'currencyId': currencyId,
        'currencyCode': currencyCode,
        'currencyName': currencyName,
        'symbol': symbol,
        'exchangeRateToBase': exchangeRateToBase,
      };
}
