import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  int id;
  bool isChecked;
  late Function(bool isChecked, int id) onCheckChanged;

  CustomCheckbox({
    Key? key,
    required this.id,
    required this.isChecked,
    required this.onCheckChanged,
  }) : super(key: key);

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // // label for checkbox
            // const Padding(
            //   padding: EdgeInsets.only(right: 5.0, left: 5.0),
            //   child: Text(""),
            // ),
            Checkbox(
              checkColor: Colors.white,
              activeColor: Colors.teal,
              tristate: false,
              value: widget.isChecked,
              onChanged: (bool? value) {
                setState(() => widget.isChecked = value!);
                widget.onCheckChanged(widget.isChecked, widget.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}