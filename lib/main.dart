import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _scanBarcodeResult = '';
  bool isDiabetic = false; // Default value
  bool shouldAvoidProduct = false; // Default value

  void _showDiabetesQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you susceptible to diabetes?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Yes'),
                leading: Radio(
                  value: true,
                  groupValue: isDiabetic,
                  onChanged: (value) {
                    setState(() {
                      isDiabetic = value!;
                    });
                    Navigator.of(context).pop();
                    _handleDiabeticStatus(value!);
                  },
                ),
              ),
              ListTile(
                title: Text('No'),
                leading: Radio(
                  value: false,
                  groupValue: isDiabetic,
                  onChanged: (value) {
                    setState(() {
                      isDiabetic = value!;
                    });
                    Navigator.of(context).pop();
                    _handleDiabeticStatus(value!);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleDiabeticStatus(bool isDiabetic) {
    // Perform actions based on the user's diabetic status.
    if (isDiabetic) {
      // If the user is diabetic, you can display a message or take other actions.
      // For example, show a message to be cautious about high-sugar products.
      setState(() {
        shouldAvoidProduct = true;
      });
    } else {
      // If the user is not diabetic, you can reset any previous warnings or actions.
      setState(() {
        shouldAvoidProduct = false;
      });
    }
  }

  void scanbarcode() async {
    // ... (barcode scanning code)
    String barcodeScanres;
    try {
      barcodeScanres = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanres = "Failed to get platform version";
    }
    setState(() {
      _scanBarcodeResult = barcodeScanres;
    });

    // Barcode values and their respective sugar contents.
    Map<String, double> productInfo = {
      '8901030807206': 45.0,
      '8901030831713': 65.0,
    };

    // Check if the scanned barcode is in the productInfo map.
    if (productInfo.containsKey(barcodeScanres)) {
      double sugarContent = productInfo[barcodeScanres]!;

      // Check if the sugar content is higher than a certain threshold (e.g., 50g).
      if (sugarContent > 50.0) {
        setState(() {
          shouldAvoidProduct = true;
        });
      } else {
        setState(() {
          shouldAvoidProduct = false;
        });
      }
    }
  }

  String getRecommendationText() {
    if (isDiabetic) {
      if (shouldAvoidProduct) {
        return "It is better to avoid this product.";
      } else {
        return "It is good to use this product.";
      }
    } else {
      return "It is good to use this product.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showDiabetesQuestionDialog,
              child: Text("Are you susceptible to diabetes?"),
            ),
            Text("Diabetic: ${isDiabetic ? 'Yes' : 'No'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanbarcode,
              child: Text("Start Barcode Scan"),
            ),
            Text("Barcode Result: $_scanBarcodeResult"),
            SizedBox(height: 20),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Provide a recommendation based on user's diabetic status and sugar content.
                String recommendation = getRecommendationText();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Product Recommendation'),
                      content: Text(recommendation),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Get Recommendation"),
            ),
          ],
        ),
      ),
    );
  }
}
