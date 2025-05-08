import 'package:flutter/material.dart';

class WheatResourceEstimatorScreen extends StatefulWidget {
  @override
  _WheatResourceEstimatorScreenState createState() =>
      _WheatResourceEstimatorScreenState();
}

class _WheatResourceEstimatorScreenState
    extends State<WheatResourceEstimatorScreen> {
  final TextEditingController _landController = TextEditingController();
  String _selectedUnit = 'Acre';
  String _detectedDisease = '';

  double? seedKg, dapBags, ureaBags, waterLiters, medicineLiters;
  double? totalSeedCost,
      totalDapCost,
      totalUreaCost,
      totalWaterCost,
      totalMedicineCost;

  final Map<String, double> unitToAcre = {
    'Acre': 1.0,
    'Kanal': 0.125,
    'Marla': 0.00625,
  };

  final double seedPricePerKg = 150;
  final double dapPricePerBag = 3500;
  final double ureaPricePerBag = 2500;
  final double waterPricePerLitre = 0.10;
  final double brownRustPricePerLitre = 1500;
  final double yellowRustPricePerLitre = 1600;

  final Color primaryColor = Color(0xFF7B5228);
  final Color accentColor = Color(0xFFE5D188);

  void _calculateResources() {
    final double? inputAmount = double.tryParse(_landController.text);
    if (inputAmount != null && inputAmount > 0) {
      double acres = inputAmount * unitToAcre[_selectedUnit]!;
      setState(() {
        seedKg = acres * 50;
        dapBags = acres * 1.25;
        ureaBags = acres * 1.5;
        waterLiters = acres * 6000;

        totalSeedCost = seedKg! * seedPricePerKg;
        totalDapCost = dapBags! * dapPricePerBag;
        totalUreaCost = ureaBags! * ureaPricePerBag;
        totalWaterCost = waterLiters! * waterPricePerLitre;

        if (_detectedDisease == 'Brown Rust') {
          medicineLiters = acres * 1.5;
          totalMedicineCost = medicineLiters! * brownRustPricePerLitre;
        } else if (_detectedDisease == 'Yellow Rust') {
          medicineLiters = acres * 2.0;
          totalMedicineCost = medicineLiters! * yellowRustPricePerLitre;
        } else {
          medicineLiters = null;
          totalMedicineCost = null;
        }
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.analytics, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildDiseaseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detected Disease (if any)'),
        ...['Brown Rust', 'Yellow Rust', 'No Disease'].map((disease) {
          return RadioListTile<String>(
            title: Text(disease),
            value: disease == 'No Disease' ? '' : disease,
            groupValue: _detectedDisease,
            activeColor: primaryColor,
            onChanged: (value) {
              setState(() {
                _detectedDisease = value!;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -1,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Top.png",
              fit: BoxFit.cover,
              height: screenHeight * 0.25,
              width: screenWidth,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Bottom.png",
              fit: BoxFit.cover,
              height: screenHeight * 0.2,
              width: screenWidth,
            ),
          ),
          Positioned(
            top: 30,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                "assets/icons/Back_arrow.png",
                height: 35,
                width: 35,
              ),
            ),
          ),
          Positioned(
            top: 25,
            right: 5,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Image.asset(
                  "assets/icons/menu.png",
                  height: 62,
                  width: 62,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.22,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Wheat Resource Estimator',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _landController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Land Area',
                            filled: true,
                            fillColor: accentColor.withOpacity(0.4),
                            prefixIcon:
                                Icon(Icons.terrain, color: primaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          underline: SizedBox(),
                          items: ['Acre', 'Kanal', 'Marla']
                              .map((unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedUnit = value!),
                          dropdownColor: Colors.white,
                          style: TextStyle(color: primaryColor),
                          iconEnabledColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDiseaseSelection(),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _calculateResources,
                    icon: Icon(Icons.calculate),
                    label: Text('Calculate Resources'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (seedKg != null) ...[
                    _buildSectionTitle('Estimation Results'),
                    _buildResultRow('Wheat Seed Required',
                        '${seedKg!.toStringAsFixed(1)} kg', Icons.grass),
                    _buildResultRow(
                        'DAP Fertilizer',
                        '${dapBags!.toStringAsFixed(2)} bags',
                        Icons.local_florist),
                    _buildResultRow('Urea Fertilizer',
                        '${ureaBags!.toStringAsFixed(2)} bags', Icons.eco),
                    _buildResultRow(
                        'Water per Irrigation',
                        '${waterLiters!.toStringAsFixed(0)} liters',
                        Icons.water_drop),
                    if (medicineLiters != null)
                      _buildResultRow(
                          'Medicine Required',
                          '${medicineLiters!.toStringAsFixed(1)} liters',
                          Icons.medication),
                    Divider(height: 32, color: primaryColor, thickness: 1),
                    _buildSectionTitle('Cost Estimations'),
                    _buildResultRow(
                        'Total Seed Cost',
                        'PKR ${totalSeedCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    _buildResultRow(
                        'Total DAP Cost',
                        'PKR ${totalDapCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    _buildResultRow(
                        'Total Urea Cost',
                        'PKR ${totalUreaCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    _buildResultRow(
                        'Total Water Cost',
                        'PKR ${totalWaterCost!.toStringAsFixed(0)}',
                        Icons.monetization_on),
                    if (totalMedicineCost != null)
                      _buildResultRow(
                          'Total Medicine Cost',
                          'PKR ${totalMedicineCost!.toStringAsFixed(0)}',
                          Icons.monetization_on),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
