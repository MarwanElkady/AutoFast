import 'dart:io';
import 'package:autoelkady/Core/components/custom_button.dart';
import 'package:autoelkady/Core/components/custom_container.dart';
import 'package:autoelkady/Core/components/custom_text_field.dart';
import 'package:autoelkady/Core/components/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:autoelkady/Core/components/custom_drop_down.dart';

class AdminPageView extends StatefulWidget {
  const AdminPageView({super.key});

  @override
  State<AdminPageView> createState() => _AdminPageViewState();
}

class _AdminPageViewState extends State<AdminPageView> {
  final TextEditingController _model = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _engine = TextEditingController();
  final TextEditingController _speed = TextEditingController();
  final TextEditingController _seats = TextEditingController();

  final List<String> brands = [
    'Bmw',
    'Lamborghini',
    'Audi',
    'Shelby',
    'Dodge',
    'Mercedes',
  ];

  String? selectedBrand;
  File? _image;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    final compressedImage = img.encodeJpg(image!, quality: 70);
    final tempDir = await Directory.systemTemp.createTemp();
    final compressedFile = File('${tempDir.path}/compressed.jpg');
    await compressedFile.writeAsBytes(compressedImage);
    return compressedFile;
  }

  Future<void> _uploadCar() async {
    /// validation
    if (_model.text.isEmpty ||
        _price.text.isEmpty ||
        _engine.text.isEmpty ||
        _speed.text.isEmpty ||
        _seats.text.isEmpty ||
        selectedBrand == null ||
        _image == null) {
      Snack().error(context, "Please fill all fields and select an image");
      return;
    }

    try {
      setState(() => isLoading = true);

      // compress and upload image
      File compressedImage = await _compressImage(_image!);
      String imageUrl = await _uploadImage(compressedImage);

      // add to Firestore
      await FirebaseFirestore.instance.collection('cars').add({
        'model': _model.text,
        'price': double.tryParse(_price.text) ?? 0.0,
        'engine': _engine.text,
        'speed': double.tryParse(_speed.text) ?? 0.0,
        'seats': int.tryParse(_seats.text) ?? 0,
        'brand': selectedBrand,
        'image': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => isLoading = false);
      Snack().success(context, "Car Added Successfully");

      /// clear fields after success
      _model.clear();
      _price.clear();
      _engine.clear();
      _speed.clear();
      _seats.clear();
      setState(() {
        selectedBrand = null;
        _image = null;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Snack().error(context, "Upload failed: $e");
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    Reference ref = FirebaseStorage.instance.ref().child(
      'cars/${DateTime.now()}.jpg',
    );
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Center(child: const Text("Admin Page")),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            /// image picker row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomContainer(
                  width: 40,
                  height: 40,
                  radius: 60,
                  color: Colors.black,
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage,
                  child: const Icon(CupertinoIcons.share_up),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// car details
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _engine,
                    hint: "Car Engine",
                    type: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: _speed,
                    hint: "Car Speed",
                    type: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: _seats,
                    hint: "Seats Number",
                    type: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _model,
              hint: "Car Model",
              type: TextInputType.text,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: _price,
              hint: "Car Price",
              type: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomDropDown(
              value: selectedBrand,
              valid: "please select at least one item",
              hint: "Choose Car Brand",
              items: brands
                  .map(
                    (brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBrand = value as String;
                });
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              onTap: _uploadCar,
              width: double.infinity,
              height: 35,
              color: Colors.black87,
              radius: 8,
              child: Center(
                child: isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text(
                        "Add Car",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
