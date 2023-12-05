import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: BMICalculator(),
    );
  }
}

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BMICalculatorForm(),
    );
  }
}

class BMICalculatorForm extends StatefulWidget {
  @override
  _BMICalculatorFormState createState() => _BMICalculatorFormState();
}

class _BMICalculatorFormState extends State<BMICalculatorForm> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  double _bmi = 0;
  String _status = '';
  String? _gender;

  late SharedPreferences prefs;

  int maleCount = 0;
  int femaleCount = 0;

  double totalMaleBMI = 0.0;
  double totalFemaleBMI = 0.0;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bmiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this); // Add observer
    displaySavedData();
  }

  Future<void> displaySavedData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      maleCount = prefs.getInt('maleCount') ?? 0;
      femaleCount = prefs.getInt('femaleCount') ?? 0;
      totalMaleBMI = prefs.getDouble('totalMaleBMI') ?? 0.0;
      totalFemaleBMI = prefs.getDouble('totalFemaleBMI') ?? 0.0;

      _nameController.text = prefs.getString('name') ?? '';
      _heightController.text = prefs.getDouble('height')?.toStringAsFixed(2) ?? '';
      _weightController.text = prefs.getDouble('weight')?.toStringAsFixed(2) ?? '';
      _gender = prefs.getString('gender') ?? ''; // Replace 'gender' with the actual key used to save gender
      _status = prefs.getString('status') ?? ''; // Replace 'status' with the actual key used to save status
      _bmi = prefs.getDouble('bmi') ?? 0.0;
      _bmiController.text = _bmi.toStringAsFixed(2);

    });
  }

  Future<void> _saveData() async {
    await prefs.setInt('maleCount', maleCount);
    await prefs.setInt('femaleCount', femaleCount);
    await prefs.setDouble('totalMaleBMI', totalMaleBMI);
    await prefs.setDouble('totalFemaleBMI', totalFemaleBMI);

    await prefs.setString('name', _nameController.text);
    await prefs.setDouble('height', double.tryParse(_heightController.text) ?? 0.0);
    await prefs.setDouble('weight', double.tryParse(_weightController.text) ?? 0.0);
    await prefs.setString('gender', _gender ?? '');
    await prefs.setString('status', _status ?? '');
    await prefs.setDouble('bmi', _bmi);
  }

  @override
  void dispose() {
    _saveData(); // Save data when the app is about to be paused or detached
    WidgetsBinding.instance?.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      displaySavedData(); // Load data when the app is resumed
    }
    super.didChangeAppLifecycleState(state);
  }

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _bmi = double.tryParse(_weightController.text)! /
            ((double.tryParse(_heightController.text)! / 100) *
                (double.tryParse(_heightController.text)! / 100));

        _bmiController.text = _bmi.toStringAsFixed(2); // Update the controller

        if (_gender == 'Male') {
          maleCount++;
          totalMaleBMI += _bmi!;
        } else {
          femaleCount++;
          totalFemaleBMI += _bmi!;
        }

        if (_gender == 'Male') {
          if (_bmi! < 18.5) {
            _status = 'Underweight. Careful during strong wind!';
          } else if (_bmi! < 25) {
            _status = 'That’s ideal! Please maintain.';
          } else if (_bmi! < 30) {
            _status = 'Overweight! Work out please.';
          } else {
            _status = 'Whoa Obese! Dangerous mate!';
          }
        } else {
          if (_bmi! < 16) {
            _status = 'Underweight. Careful during strong wind!';
          } else if (_bmi! < 22) {
            _status = 'That’s ideal! Please maintain.';
          } else if (_bmi! < 27) {
            _status = 'Overweight! Work out please.';
          } else {
            _status = 'Whoa Obese! Dangerous mate!';
          }
        }

        _saveData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Fullname',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height in cm',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              TextField(
                controller: _bmiController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'BMI Value',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Male'),
                      leading: Radio(
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value as String?;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Female'),
                      leading: Radio(
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value as String?;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _calculateBMI,
                child: Text('Calculate BMI and Save'),
              ),
              Center(
                child: Text(
                  ' $_status',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'Total BMI for Male: $maleCount, Total BMI for Female: $femaleCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Average Male BMI: ${maleCount == 0 ? 0 : (totalMaleBMI / maleCount).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Average Female BMI: ${femaleCount == 0 ? 0 : (totalFemaleBMI / femaleCount).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
