import 'package:flutter/material.dart';
import '../services/genesis_market_symbols.dart';
import '../services/genesis_crypto_prices.dart';

class GenesisMarketWatch extends StatefulWidget {
  const GenesisMarketWatch({super.key});
  @override
  State<GenesisMarketWatch> createState() => _GenesisMarketWatchState();
}

class _GenesisMarketWatchState extends State<GenesisMarketWatch> {
  String category = "All";
  Map<String, double> cryptoPrices = {};
  bool cryptoLoading = false;
  String? cryptoError;
  DateTime? cryptoUpdated;
  @override
  void initState() {
    super.initState();
    refreshCrypto();
  }

  Future<void> refreshCrypto() async {
    if (cryptoLoading) return;
    setState(() {
      cryptoLoading = true;
      cryptoError = null;
    });
    try {
      final prices = await GenesisCryptoPrices.fetch();
      if (!mounted) return;
      setState(() {
        cryptoPrices = prices;
        cryptoUpdated = DateTime.now();
        cryptoLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        cryptoError = error.toString();
        cryptoLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00DFFF);
    const gold = Color(0xFFFFD700);
    final symbols = genesisMarketSymbols
        .where((item) => category == "All" || item["category"] == category)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "9³ MARKET WATCH • ASSET DIRECTORY",
          style: TextStyle(
            color: cyan,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            const Expanded(
              child: Text(
                "CoinGecko • BTC / ETH / SOL / XRP",
                style: TextStyle(color: gold, fontSize: 10),
              ),
            ),
            IconButton(
              tooltip: "Refresh Crypto Prices",
              onPressed: cryptoLoading ? null : refreshCrypto,
              icon: const Icon(Icons.refresh, color: gold, size: 17),
              constraints: const BoxConstraints(minWidth: 30, minHeight: 26),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: category,
                isExpanded: true,
                isDense: true,
                underline: const SizedBox.shrink(),
                style: const TextStyle(color: Colors.white, fontSize: 11),
                items: ["All", "ETFs", "Stocks", "Forex", "Crypto"]
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
              ),
            ),
            Text(
              "${symbols.length} assets",
              style: const TextStyle(color: gold, fontSize: 10),
            ),
          ],
        ),
        const Divider(height: 10, color: Color(0x4455BBDD)),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: symbols.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 7, color: Color(0x2233AADD)),
            itemBuilder: (context, index) {
              final item = symbols[index];
              final symbol = item["symbol"] ?? "";
              final group = item["category"] ?? "";
              final price = cryptoPrices[symbol];
              final priceText = price == null
                  ? null
                  : price >= 1
                  ? price.toStringAsFixed(2)
                  : price.toStringAsFixed(6);
              return Row(
                children: [
                  Icon(
                    group == "Crypto"
                        ? Icons.currency_bitcoin
                        : group == "Forex"
                        ? Icons.currency_exchange
                        : Icons.show_chart,
                    color: cyan,
                    size: 13,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (priceText != null) ...[
                    Text(
                      String.fromCharCode(36) + priceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    group,
                    style: const TextStyle(color: gold, fontSize: 10),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          "Market directory • Quotes not yet connected",
          style: TextStyle(color: gold, fontSize: 9),
        ),
      ],
    );
  }
}
