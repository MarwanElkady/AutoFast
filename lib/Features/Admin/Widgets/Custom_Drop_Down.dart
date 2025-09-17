import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDropDown extends StatelessWidget {
  const CustomDropDown({
    super.key,
    this.value,
    required this.Valid,
    required this.hint,
    this.items,
    required this.onChanged,
  });
  final String? value;
  final String Valid, hint;
  final List<DropdownMenuItem<String>>? items;
  final Function(dynamic v) onChanged;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: DropdownButtonFormField2(
        value: value,
        validator: (value) => value == null ? Valid : null,
        items: items,
        onChanged: onChanged,

        isDense: true,
        hint: Text(hint, style: TextStyle(fontSize: 15, color: Colors.grey)),
        iconStyleData: IconStyleData(
          icon: Icon(Icons.arrow_forward_ios, size: 10),
        ),
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.black),
          contentPadding: EdgeInsets.all(10),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
