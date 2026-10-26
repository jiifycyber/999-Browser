import "package:flutter/material.dart";

class ForexTradingShell extends StatelessWidget {
  const ForexTradingShell({super.key});
  static const gold = Color(0xFFFFC857);
  static const cyan = Color(0xFF21D8FF);
  static const panel = Color(0xFF0B1930);
  Widget tile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(color: cyan.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030B1C),
      appBar: AppBar(
        backgroundColor: panel,
        title: const Text(
          "999 FOREX TRADING",
          style: TextStyle(color: gold, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "GLOBAL FOREX TERMINAL",
            style: TextStyle(
              color: cyan,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "DEMO INTERFACE - NO LIVE MARKET CONNECTION",
            style: TextStyle(color: gold, fontSize: 12),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: constraints.maxWidth > 700 ? 1.8 : 1.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  tile("EUR/USD", "1.0000 DEMO", Icons.currency_exchange),
                  tile("GBP/USD", "1.0000 DEMO", Icons.show_chart),
                  tile("USD/JPY", "150.00 DEMO", Icons.trending_up),
                  tile("MARKET STATUS", "NOT CONNECTED", Icons.sensors_off),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cyan.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.candlestick_chart, color: cyan, size: 64),
                  SizedBox(height: 12),
                  Text(
                    "ADVANCED FOREX CHART",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Awaiting market data integration",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          tile(
            "999 AI SIGNAL INTELLIGENCE",
            "AWAITING CONNECTION",
            Icons.psychology,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  child: const Text("BUY - DISABLED"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  child: const Text("SELL - DISABLED"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
