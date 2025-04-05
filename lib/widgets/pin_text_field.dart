import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';

class PinEntryTextField extends StatefulWidget {
  int fields;
  var onSubmit;
  double fieldWidth;
  double fontSize;
  bool isTextObscure;
  bool showFieldAsBox;

  PinEntryTextField(
      {this.fields = 4,
      this.onSubmit,
      this.fieldWidth = 35.0,
      this.fontSize = 18.0,
      this.isTextObscure = false,
      this.showFieldAsBox = false,
      Key key = K.pinTextField})
      : super(key: key);

  @override
  State createState() {
    return PinEntryTextFieldState();
  }
}

class PinEntryTextFieldState extends State<PinEntryTextField> {
  late List<String> _pin;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _textControllers;

  PinEntryTextFieldState();

  @override
  void initState() {
    super.initState();
    _pin = List.generate(widget.fields.ceil(), (index) => '');
    _focusNodes = List.generate(widget.fields.ceil(), (index) => FocusNode());
    _textControllers =
        List.generate(widget.fields.ceil(), (index) => TextEditingController());
  }

  @override
  void dispose() {
    _focusNodes.forEach((FocusNode f) => f.dispose());
    _textControllers.forEach((TextEditingController t) => t.dispose());
    super.dispose();
  }

  void clearTextFields() {
    _textControllers.forEach(
        (TextEditingController tEditController) => tEditController.clear());
  }

  Widget buildTextField(int i, BuildContext context) {
    //_focusNodes[i] = FocusNode();
    // _textControllers[i] = TextEditingController();
    _textControllers[i].text = _pin[i];

    _focusNodes[i].addListener(() {
      if (_focusNodes[i].hasFocus) {
        _textControllers[i].clear();
      }
    });

    return Container(
      width: widget.fieldWidth,
      margin: EdgeInsets.only(right: 10.0),
      child: TextField(
        controller: _textControllers[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: widget.fontSize),
        focusNode: _focusNodes[i],
        obscureText: widget.isTextObscure,
        decoration: InputDecoration(
            counterText: "",
            border: widget.showFieldAsBox
                ? OutlineInputBorder(borderSide: BorderSide(width: 2.0))
                : null),
        onChanged: (String str) {
          _pin[i] = str;
          if (i + 1 != widget.fields) {
            FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
          } else {
            widget.onSubmit(_pin.join());
          }
        },
        onSubmitted: (String str) {
          //clearTextFields();
          widget.onSubmit(_pin.join());
        },
      ),
    );
  }

  Widget generateTextFields(BuildContext context) {
    List<Widget> textFields = List.generate(widget.fields, (int i) {
      return buildTextField(i, context);
    });

    //FocusScope.of(context).requestFocus(_focusNodes[0]);

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: textFields);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: generateTextFields(context),
    );
  }
}
