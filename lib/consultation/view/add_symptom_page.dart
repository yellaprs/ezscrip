import 'package:ezscrip/consultation/model/medicalDictionary.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import '../../util/semantics.dart' as semantic;
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AddSymptomPage extends StatefulWidget {
  const AddSymptomPage({Key? key}) : super(key: key);

  @override
  _AddSymtomPageState createState() => _AddSymtomPageState();
}

class _AddSymtomPageState extends State<AddSymptomPage> {
  late TextEditingController _symptomTextController;
  late GlobalKey<FormState> _formKey;
  _AddSymtomPageState();
  late String _symptomName;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _symptomTextController = TextEditingController();
    _symptomName = "";
    _symptomTextController.text = _symptomName;
    super.initState();
  }

  List<String> getMedicalDict(String searchStr) {
    List<String> medWords = GetIt.instance<MedicalDictionary>().words;
    medWords.retainWhere((element) => element.startsWith(searchStr));
    return medWords;
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            key: K.closeButton,
            icon: const Icon(
              Foundation.x,
              size: UI.DIALOG_ACTION_BTN_SIZE,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        Container(
            alignment: Alignment.center,
            child: AutoSizeText(
                "${AppLocalizations.of(context)!.addSymptom}",
                style: Theme.of(context).textTheme.titleLarge)),
        IconButton(
            key: K.checkButton,
            icon: const Icon(Foundation.check,
                size: UI.DIALOG_ACTION_BTN_SIZE,
                semanticLabel: semantic.S.ADD_SYMPTOM_DONE_BUTTON),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.of(context).pop(_symptomName);
              }
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: K.addSymptomsSlide,
      height: (MediaQuery.of(context).size.height * 3) / 4,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    alignment: Alignment.center,
                    child: buildHeader()),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                height: 60,
                                child: Semantics(
                                    identifier: semantic.S.ADD_SYMPTOM_NAME_FLD,
                                    child: TypeAheadField<String>(
                                      key: K.symptomNameAutoSizeTextField,
                                      direction: VerticalDirection.down,
                                      controller: _symptomTextController,
                                      builder: (context, controller,
                                              focusNode) =>
                                          TextFormField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              autofocus: true,
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style
                                                      .copyWith(
                                                          fontStyle:
                                                              FontStyle.italic),
                                              decoration: const InputDecoration(
                                                border: UnderlineInputBorder(),
                                                hintText: '',
                                              ),
                                              validator: (val) {
                                                if (val?.isEmpty ?? true) {
                                                  return AppLocalizations.of(
                                                          context)!
                                                      .isRequired(
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .symptoms);
                                                }
                                                return null;
                                              },
                                              onSaved: (suggestion) {
                                                _symptomName =
                                                    suggestion.toString();
                                                _symptomTextController.text =
                                                    _symptomName;
                                              }),
                                      decorationBuilder: (context, child) =>
                                          Material(
                                        type: MaterialType.card,
                                        elevation: 4,
                                        borderRadius: const BorderRadius.all( Radius.circular(8)),
                                        child: child,
                                      ),
                                      itemBuilder: (context, suggestion) =>
                                          ListTile(
                                        title: Text(suggestion),
                                      ),
                                      debounceDuration: const Duration(milliseconds: 400),
                                      hideOnEmpty: true,
                                      hideOnSelect: true,
                                      hideOnUnfocus: true,
                                      hideWithKeyboard: true,
                                      retainOnLoading: false,
                                      onSelected: (suggestion) {
                                        _symptomTextController.text =
                                            suggestion;
                                      },
                                      suggestionsCallback: (pattern) async {
                                        if (pattern.isNotEmpty) {
                                          return Future.sync(() =>
                                              getMedicalDict(
                                                  pattern.toLowerCase()));
                                        } else {
                                          return [];
                                        }
                                      },
                                    )),
                              ))
                        ])),
              ])),
    );
  }
}
