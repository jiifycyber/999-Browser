import 'package:flutter/material.dart';

void main() {
  runApp(const JiffyPriceCalculatorApp());
}

class JiffyPriceCalculatorApp extends StatelessWidget {
  const JiffyPriceCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jiffy Roadside Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PriceCalculatorPage(),
    );
  }
}

class PriceCalculatorPage extends StatefulWidget {
  const PriceCalculatorPage({super.key});

  @override
  State<PriceCalculatorPage> createState() =>
      _PriceCalculatorPageState();
}

class _PriceCalculatorPageState extends State<PriceCalculatorPage> {
  final TextEditingController serviceCallController =
  TextEditingController(text: '125.00');

  final TextEditingController partsCostController =
  TextEditingController();

  final TextEditingController taxRateController =
  TextEditingController(text: '10.00');

  String selectedService = 'Tire Replacement';

  double subtotal = 0;
  double taxAmount = 0;
  double total = 0;

  final List<String> services = [
    'Tire Replacement',
    'Tire Change',
    'Jump Start',
    'Battery Replacement',
    'Vehicle Lockout',
    'Fuel Delivery',
    'Other Roadside Service',
  ];

  void calculatePrice() {
    final double serviceCall =
        double.tryParse(serviceCallController.text) ?? 0;

    final double partsCost =
        double.tryParse(partsCostController.text) ?? 0;

    final double taxRate =
        double.tryParse(taxRateController.text) ?? 0;
    final double markedUpPartsCost = partsCost * 1.80;

    setState(() {
      subtotal = serviceCall + markedUpPartsCost;
      taxAmount = subtotal * (taxRate / 100);
      total = subtotal + taxAmount;
    });

    FocusScope.of(context).unfocus();
  }

  void clearCalculator() {
    setState(() {
      serviceCallController.text = '125.00';
      partsCostController.clear();
      taxRateController.text = '10.00';
      selectedService = 'Tire Replacement';
      subtotal = 0;
      taxAmount = 0;
      total = 0;
    });
  }

  Widget buildMoneyField({
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildPriceRow(
      String label,
      double amount, {
        bool emphasize = false,
      }) {
    final TextStyle style = TextStyle(
      fontSize: emphasize ? 24 : 18,
      fontWeight:
      emphasize ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    serviceCallController.dispose();
    partsCostController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jiffy Roadside Calculator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.car_repair,
                size: 75,
              ),
              const SizedBox(height: 10),

              const Text(
                'Jiffy Roadside Assistance Corporation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                '313-952-5266',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17),
              ),

              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                value: selectedService,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                ),
                items: services.map((service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedService = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              buildMoneyField(
                label: 'Service Call',
                controller: serviceCallController,
                prefix: '\$ ',
              ),

              const SizedBox(height: 16),

              buildMoneyField(
                label: 'Tire, Battery, Parts or Fuel Cost',
                controller: partsCostController,
                prefix: '\$ ',
              ),

              const SizedBox(height: 16),

              buildMoneyField(
                label: 'Sales Tax Rate',
                controller: taxRateController,
                suffix: ' %',
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: calculatePrice,
                icon: const Icon(Icons.calculate),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Calculate Customer Total',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: clearCalculator,
                child: const Text('Clear Calculator'),
              ),

              const SizedBox(height: 25),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        selectedService,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Divider(height: 25),

                      buildPriceRow('Subtotal', subtotal),
                      buildPriceRow('Tax', taxAmount),

                      const Divider(height: 25),

                      buildPriceRow(
                        'Customer Total',
                        total,
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Service prices should be confirmed before dispatch.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
