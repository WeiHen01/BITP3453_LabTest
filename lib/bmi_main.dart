import 'package:bitp3453_labtest/Controller/sqflite.dart';
import 'package:bitp3453_labtest/model/bmi.dart';
import 'package:flutter/material.dart';

class BMIHome extends StatefulWidget {
  const BMIHome({super.key});

  @override
  State<BMIHome> createState() => _BMIHomeState();
}

class _BMIHomeState extends State<BMIHome> {

  String gender = "";
  double bmi = 0.0;
  String bmiResult = "";
  String bmiStatus = "";
  String statusMsg = "";

  double averageBMIMale = 0.0;
  double averageBMIFemale = 0.0;
  int countMale = 0;
  int countFemale = 0;


  TextEditingController nameCtrl = TextEditingController();
  TextEditingController weightCtrl = TextEditingController();
  TextEditingController heightCtrl = TextEditingController();

  SQFlite sqlite = SQFlite();

  // Calculates the BMI using the BMIModel
  void calculateBMI() {
    double weight = double.parse(weightCtrl.text);
    double height = double.parse(heightCtrl.text);

    bmi = weight / (height/100 * height/100);
    bmiResult = bmi.toStringAsFixed(2);
    if (gender == 'Male') {
      if (bmi < 18.5) {
        bmiStatus = "Underweight! Careful during strong wind!";
      } else if (bmi >= 18.5 && bmi < 25) {
        bmiStatus = "That's ideal! Please maintain.";
      } else if (bmi >= 25 && bmi < 30) {
        bmiStatus = "Overweight! Work out please.";
      } else {
        bmiStatus = "Whoa Obese! Dangerous mate!";
      }
    } else if (gender == 'Female') {
      if (bmi < 16) {
        bmiStatus = "Underweight! Careful during strong wind!";
      } else if (bmi >= 16 && bmi < 22) {
        bmiStatus = "That's ideal! Please maintain.";
      } else if (bmi >= 22 && bmi < 27) {
        bmiStatus = "Overweight! Work out please.";
      } else {
        bmiStatus = "Whoa Obese! Dangerous mate!";
      }
    } else {
      // Handle other genders if needed
      bmiStatus = "Unknown gender";
    }

    setState(() {
      statusMsg = bmiStatus;
    });
  }

  // Loads the most recent data from the SQLite database
  Future<void> loadPreviousData(SQFlite sqliteController) async {
    final data = await sqliteController.getPreviousData();
    if (data != null) {
      nameCtrl.text = data['fullname'];
      weightCtrl.text = data['weight'].toString();
      heightCtrl.text = data['height'].toString();

      if ((data['gender']) != null) {
        gender = (data['gender']);
      }

      bmiResult = data['bmi'].toString();
      bmiStatus = data['status'];
    }
  }

  void loadPreviousDatafromLocal() async {
    await loadPreviousData(sqlite);
    if (mounted) {
      setState(() {});
    }
  }

  void getAnalysis() async {
    averageBMIMale = await sqlite.calculateAverageBMI('Male');
    averageBMIFemale = await sqlite.calculateAverageBMI('Female');
    countMale = await sqlite.countGender('Male');
    countFemale = await sqlite.countGender('Female');
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPreviousDatafromLocal();
    getAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator", style: TextStyle(
          color: Colors.white
      ),), backgroundColor: Colors.blue,),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Your fullname',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height in cm: 170',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight in KG',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: weightCtrl,
                  enabled: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Your BMI Value:',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio<String>(
                    value: 'Male',
                    groupValue: gender,
                    onChanged: (String? value) {
                      setState(() {
                        if(value != null){
                          gender = value;
                        }
                      });
                    },
                  ),
                  Text('Male'),
                  Radio<String>(
                    value: 'Female',
                    groupValue: gender,
                    onChanged: (String? value) {
                      setState(() {
                        if(value != null){
                          gender = value;
                        }
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),



              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  calculateBMI();
                  sqlite.insertBMIRecord(nameCtrl.text,
                      double.parse(heightCtrl.text),
                      double.parse(weightCtrl.text),
                      gender, bmi, statusMsg);
                },
                child: Text('Calculate BMI and Save'),
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                  foregroundColor: MaterialStatePropertyAll(Colors.white)
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Gender: ${gender}, ',),
                  SizedBox(width: 10,),
                  Text('Status: ${statusMsg}'),
                ],
              ),

              SizedBox(height: 20),
              Divider(
                thickness: 2.0,
              ),
              Text("Average", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),),
              Divider(
                thickness: 2.0,
              ),
              Text('Average Male BMI: ${averageBMIMale.toStringAsFixed(2)}',style: TextStyle(
                fontSize: 20,
              ),),
              Text('Average Female BMI: ${averageBMIFemale.toStringAsFixed(2)}', style: TextStyle(
                fontSize: 20,
              ),),
              Divider(
                thickness: 2.0,
              ),
              Text("Total", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
              ),),
              Divider(
                thickness: 2.0,
              ),
              Text('Total Male records: ${countMale}', style: TextStyle(
                fontSize: 20,
              ),),
              Text('Total Female records: ${countFemale}', style: TextStyle(
                fontSize: 20,
              ),),

            ],
          ),
        ),
      ),
    );
  }
}
