import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  // --- Text Controllers ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // --- Blockchain Connection Details (loaded from .env) ---
  late Web3Client ethClient;
  final String rpcUrl = dotenv.env['GANACHE_RPC_URL']!;
  final String privateKey = dotenv.env['GANACHE_PRIVATE_KEY']!;
  final String contractAddress = dotenv.env['CONTRACT_ADDRESS']!;

  // --- State Variables ---
  DeployedContract? contract;
  Credentials? credentials;
  String status = "Initializing...";
  int patientCount = 0;
  bool isLoading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    initSetup();
  }

  Future<void> initSetup() async {
    ethClient = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);

    String abi = '''[
      { "inputs": [ {"internalType": "string","name": "_name","type": "string"}, {"internalType": "uint256","name": "_age","type": "uint256"}, {"internalType": "string","name": "_ultrasoundHash","type": "string"} ], "name": "addPatient", "outputs": [], "stateMutability": "nonpayable", "type": "function" },
      { "inputs": [{"internalType": "uint256","name": "_id","type": "uint256"}], "name": "getPatient", "outputs": [ {"internalType": "string","name": "","type": "string"}, {"internalType": "uint256","name": "","type": "uint256"}, {"internalType": "string","name": "","type": "string"} ], "stateMutability": "view", "type": "function" },
      { "inputs": [], "name": "patientCount", "outputs": [{"internalType": "uint256","name": "","type": "uint256"}], "stateMutability": "view", "type": "function" },
      { "inputs": [{"internalType": "uint256","name": "","type": "uint256"}], "name": "patients", "outputs": [ {"internalType": "string","name": "name","type": "string"}, {"internalType": "uint256","name": "age","type": "uint256"}, {"internalType": "string","name": "ultrasoundHash","type": "string"} ], "stateMutability": "view", "type": "function" }
    ]''';

    // final contractAddr = EthereumAddress.fromHex(contractAddress);
    // contract = DeployedContract(
    //   ContractAbi.fromJson(abi, "PatientRecords"),
    //   contractAddr,
    // );
    await getPatientCount();
    setState(() {
      isLoading = false;
      status = "Connected to Ganache ✅";
    });
  }

  Future<void> addPatient(String name, int age, String hash) async {
    final addFn = contract!.function("addPatient");
    await ethClient.sendTransaction(
      credentials!,
      Transaction.callContract(
        contract: contract!,
        function: addFn,
        parameters: [name, BigInt.from(age), hash],
      ),
      chainId: 1337, // Ganache default chain ID
    );
    await getPatientCount(); // Refresh the count after adding
  }

  Future<void> getPatientCount() async {
    try {
      final countFn = contract!.function("patientCount");
      final result = await ethClient.call(
        contract: contract!,
        function: countFn,
        params: [],
      );
      setState(() {
        patientCount = (result[0] as BigInt).toInt();
      });
    } catch (e) {
      debugPrint("Error getting patient count: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient Record")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "$status | Total Patients: $patientCount",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "➕ Add New Patient",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Patient Name",
                        ),
                      ),
                      TextField(
                        controller: ageController,
                        decoration: const InputDecoration(
                          labelText: "Patient Age",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      if (_selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.image_search),
                        label: Text(
                          _selectedImage == null
                              ? "Select Ultrasound Scan"
                              : "Change Scan",
                        ),
                        onPressed: _pickImage,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          final age = int.tryParse(ageController.text);

                          if (nameController.text.isEmpty ||
                              age == null ||
                              _selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill all fields and select an image.",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            // 1. Upload to Supabase
                            final imageFile = _selectedImage!;
                            final fileName =
                                '${DateTime.now().millisecondsSinceEpoch}.jpg';
                            await Supabase.instance.client.storage
                                .from('ultrasounds')
                                .upload(fileName, imageFile);

                            // 2. Get the public URL
                            final imageUrl = Supabase.instance.client.storage
                                .from('ultrasounds')
                                .getPublicUrl(fileName);

                            // 3. Save the URL to the blockchain
                            await addPatient(
                              nameController.text,
                              age,
                              imageUrl,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Success! Patient record and scan saved.",
                                ),
                              ),
                            );

                            // Clear the form
                            setState(() {
                              _selectedImage = null;
                              nameController.clear();
                              ageController.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                        child: const Text("Submit Patient Record"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
