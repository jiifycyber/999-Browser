import 'dart:convert';
import 'package:http/http.dart' as http;

class GenesisCryptoPrices {
  static const coinIds = <String, String>{
    "BTC": "bitcoin",
    "ETH": "ethereum",
    "SOL": "solana",
    "XRP": "ripple",
    "BNB": "binancecoin",
    "ADA": "cardano",
    "DOGE": "dogecoin",
    "AVAX": "avalanche-2",
    "LINK": "chainlink",
    "DOT": "polkadot",
    "LTC": "litecoin",
    "BCH": "bitcoin-cash",
    "XLM": "stellar",
    "HBAR": "hedera-hashgraph",
    "UNI": "uniswap",
    "AAVE": "aave",
    "NEAR": "near",
    "ATOM": "cosmos",
    "FIL": "filecoin",
    "ETC": "ethereum-classic",
    "ALGO": "algorand",
    "ICP": "internet-computer",
    "ARB": "arbitrum",
    "OP": "optimism",
    "SUI": "sui",
  };
  static Future<Map<String, double>> fetch() async {
    final uri = Uri.https("api.coingecko.com", "/api/v3/simple/price", {
      "ids": coinIds.values.join(","),
      "vs_currencies": "usd",
    });
    final response = await http
        .get(uri, headers: {"Accept": "application/json"})
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception("CoinGecko HTTP \${response.statusCode}");
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final prices = <String, double>{};
    for (final entry in coinIds.entries) {
      final coin = data[entry.value];
      if (coin is Map && coin["usd"] is num) {
        prices[entry.key] = (coin["usd"] as num).toDouble();
      }
    }
    return prices;
  }
}
