import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/semantics.dart' as semantic;
import '../../util/keys.dart';

class AddTestsPage extends StatefulWidget {
  const AddTestsPage({Key? key}) : super(key: key);

  @override
  _AddTestsPageState createState() => _AddTestsPageState();
}

class _AddTestsPageState extends State<AddTestsPage> {
  late TextEditingController _testController;
  late String _investigationName;
  late GlobalKey<FormState> _formKey;
  _AddTestsPageState();

  @override
  void initState() {
    _investigationName = "";
    _formKey = GlobalKey<FormState>();
    _testController = TextEditingController();
    _testController.text = _investigationName;
    super.initState();
  }

  Widget buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          key: K.closeButton,
          icon: const Icon(Foundation.x, size: UI.DIALOG_ACTION_BTN_SIZE),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      Container(
          alignment: Alignment.center,
          child: AutoSizeText(
              " ${AppLocalizations.of(context)!.addInvestigation}",
              style: Theme.of(context).textTheme.titleLarge)),
      IconButton(
          key: K.checkButton,
          icon: const Icon(Foundation.check,
              size: UI.DIALOG_ACTION_BTN_SIZE,
              semanticLabel: semantic.S.ADD_INVESTIGATION_DONE_BUTTON),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop(_investigationName);
            }
          })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: (MediaQuery.of(context).size.height * 3) / 4,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Form(
            key: _formKey,
            child: Stack(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      alignment: Alignment.center,
                      child: buildHeader()),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height: 60,
                                  child: Semantics(
                                      identifier:
                                          semantic.S.ADD_INVESTIGATION_NAME_FLD,
                                      container: true,
                                      child: TextField(
                                        key: K.testName,
                                        controller: _testController,
                                        onChanged: (val) {
                                          _investigationName = val;
                                        },
                                        onSubmitted: (val) {
                                          _investigationName = val;
                                        },
                                        decoration: InputDecoration(
                                          labelText:
                                              "${AppLocalizations.of(context)!.name} (e.g Complete Blood Profile)",
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      Colors.lightBlue[100]!),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                        ),
                                      ))),
                            ),
                          ]))
                ],
              )
            ])));
  }
}
