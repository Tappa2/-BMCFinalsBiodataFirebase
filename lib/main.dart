import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BioDataApp());
}

class BioDataApp extends StatelessWidget {
  const BioDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bio-Data',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF173F5F),
        ),
        fontFamily: 'Arial',
      ),
      home: const BioDataPage(),
    );
  }
}

class BioDataPage extends StatefulWidget {
  const BioDataPage({super.key});

  @override
  State<BioDataPage> createState() => _BioDataPageState();
}

class _BioDataPageState extends State<BioDataPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final ageController = TextEditingController();
  final civilStatusController = TextEditingController();
  final nationalityController = TextEditingController();
  final religionController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  final elementaryController = TextEditingController();
  final seniorHighController = TextEditingController();
  final collegeController = TextEditingController();
  final courseController = TextEditingController();

  final skillsController = TextEditingController();

  final positionController = TextEditingController();
  final companyController = TextEditingController();
  final workYearsController = TextEditingController();

  final certificationController = TextEditingController();
  final signatureController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? imageBytes;
  String? imageName;

  bool isSaving = false;

  @override
  void dispose() {
    fullNameController.dispose();
    birthDateController.dispose();
    ageController.dispose();
    civilStatusController.dispose();
    nationalityController.dispose();
    religionController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();

    elementaryController.dispose();
    seniorHighController.dispose();
    collegeController.dispose();
    courseController.dispose();

    skillsController.dispose();

    positionController.dispose();
    companyController.dispose();
    workYearsController.dispose();

    certificationController.dispose();
    signatureController.dispose();

    super.dispose();
  }

  Future<void> pickProfilePicture() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        imageBytes = bytes;
        imageName = image.name;
      });
    } catch (e) {
      showMessage('Unable to select picture.');
    }
  }

  Future<String?> uploadProfilePicture() async {
    if (imageBytes == null) return null;

    final safeName = imageName ?? 'profile.jpg';
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$safeName';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child(fileName);

    String contentType = 'image/jpeg';

    final lowerName = safeName.toLowerCase();

    if (lowerName.endsWith('.png')) {
      contentType = 'image/png';
    } else if (lowerName.endsWith('.webp')) {
      contentType = 'image/webp';
    }

    await storageRef.putData(
      imageBytes!,
      SettableMetadata(
        contentType: contentType,
      ),
    );

    return await storageRef.getDownloadURL();
  }

  Future<void> saveData() async {
    if (!_formKey.currentState!.validate()) {
      showMessage('Please fill in the required fields.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? imageUrl;

      if (imageBytes != null) {
        imageUrl = await uploadProfilePicture();
      }

      await FirebaseFirestore.instance.collection('biodata').add({
        'fullName': fullNameController.text.trim(),
        'birthDate': birthDateController.text.trim(),
        'age': ageController.text.trim(),
        'civilStatus': civilStatusController.text.trim(),
        'nationality': nationalityController.text.trim(),
        'religion': religionController.text.trim(),
        'email': emailController.text.trim(),
        'contactNumber': contactController.text.trim(),
        'address': addressController.text.trim(),

        'education': {
          'elementary': elementaryController.text.trim(),
          'seniorHighSchool': seniorHighController.text.trim(),
          'college': collegeController.text.trim(),
          'course': courseController.text.trim(),
        },

        'skills': skillsController.text.trim(),

        'workExperience': {
          'position': positionController.text.trim(),
          'company': companyController.text.trim(),
          'years': workYearsController.text.trim(),
        },

        'certification': certificationController.text.trim(),
        'signature': signatureController.text.trim(),

        'profileImageUrl': imageUrl,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage(
        'Bio-data saved successfully!',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Failed to save data. Check your Firebase settings.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void clearForm() {
    fullNameController.clear();
    birthDateController.clear();
    ageController.clear();
    civilStatusController.clear();
    nationalityController.clear();
    religionController.clear();
    emailController.clear();
    contactController.clear();
    addressController.clear();

    elementaryController.clear();
    seniorHighController.clear();
    collegeController.clear();
    courseController.clear();

    skillsController.clear();

    positionController.clear();
    companyController.clear();
    workYearsController.clear();

    certificationController.clear();
    signatureController.clear();

    setState(() {
      imageBytes = null;
      imageName = null;
    });

    showMessage('Form cleared.');
  }

  void showMessage(
    String message, {
    bool success = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget sectionTitle(
    String title,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 25,
        bottom: 15,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEAF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF173F5F),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF173F5F),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget textField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF173F5F),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget responsiveTwoColumns(
    BuildContext context,
    List<Widget> children,
  ) {
    final width = MediaQuery.of(context).size.width;

    if (width < 700) {
      return Column(
        children: children,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: children[0],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: children[1],
        ),
      ],
    );
  }

  Widget profilePicture() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF173F5F),
                width: 2,
              ),
            ),
            child: imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 65,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'No Picture',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: pickProfilePicture,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Picture'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF173F5F),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'BIO-DATA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1000,
            ),
            child: Card(
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'PERSONAL BIO-DATA FORM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F5F),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Center(
                        child: Text(
                          'Please complete all required information.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      profilePicture(),

                      sectionTitle(
                        'Personal Information',
                        Icons.person,
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'Full Name',
                            fullNameController,
                            required: true,
                          ),
                          textField(
                            'Date of Birth',
                            birthDateController,
                            hint: 'MM/DD/YYYY',
                          ),
                        ],
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'Age',
                            ageController,
                            keyboardType:
                                TextInputType.number,
                          ),
                          textField(
                            'Civil Status',
                            civilStatusController,
                          ),
                        ],
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'Nationality',
                            nationalityController,
                          ),
                          textField(
                            'Religion',
                            religionController,
                          ),
                        ],
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'Email Address',
                            emailController,
                            keyboardType:
                                TextInputType.emailAddress,
                          ),
                          textField(
                            'Contact Number',
                            contactController,
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ],
                      ),

                      textField(
                        'Complete Address',
                        addressController,
                        maxLines: 2,
                      ),

                      sectionTitle(
                        'Educational Background',
                        Icons.school,
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'Elementary School',
                            elementaryController,
                          ),
                          textField(
                            'Senior High School',
                            seniorHighController,
                          ),
                        ],
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'College / University',
                            collegeController,
                          ),
                          textField(
                            'Course / Program',
                            courseController,
                          ),
                        ],
                      ),

                      sectionTitle(
                        'Skills',
                        Icons.star,
                      ),

                      textField(
                        'Skills',
                        skillsController,
                        maxLines: 4,
                        hint:
                            'Example: Programming, Communication, Teamwork',
                      ),

                      sectionTitle(
                        'Work Experience',
                        Icons.work,
                      ),

                      responsiveTwoColumns(
                        context,
                        [
                          textField(
                            'Position / Job Title',
                            positionController,
                          ),
                          textField(
                            'Company / Organization',
                            companyController,
                          ),
                        ],
                      ),

                      textField(
                        'Years of Experience',
                        workYearsController,
                      ),

                      sectionTitle(
                        'Certification / Signature',
                        Icons.verified,
                      ),

                      textField(
                        'Certification',
                        certificationController,
                        maxLines: 2,
                      ),

                      textField(
                        'Signature / Full Name',
                        signatureController,
                      ),

                      const SizedBox(height: 25),

                      const Divider(),

                      const SizedBox(height: 20),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 500) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      isSaving
                                          ? null
                                          : saveData,
                                  icon: isSaving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.save,
                                        ),
                                  label: Text(
                                    isSaving
                                        ? 'Saving...'
                                        : 'SAVE DATA',
                                  ),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(
                                      0xFF173F5F,
                                    ),
                                    foregroundColor:
                                        Colors.white,
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed:
                                      isSaving
                                          ? null
                                          : clearForm,
                                  icon: const Icon(
                                    Icons.clear_all,
                                  ),
                                  label: const Text(
                                    'CLEAR FORM',
                                  ),
                                  style:
                                      OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    isSaving
                                        ? null
                                        : saveData,
                                icon: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  isSaving
                                      ? 'Saving...'
                                      : 'SAVE DATA',
                                ),
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF173F5F),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              OutlinedButton.icon(
                                onPressed:
                                    isSaving
                                        ? null
                                        : clearForm,
                                icon: const Icon(
                                  Icons.clear_all,
                                ),
                                label: const Text(
                                  'CLEAR FORM',
                                ),
                                style:
                                    OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      const Center(
                        child: Text(
                          'Your information will be saved securely in Firebase.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
