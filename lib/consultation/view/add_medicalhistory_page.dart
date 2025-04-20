import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:ezscrip/consultation/model/diseaseGlossary.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:validatorless/validatorless.dart';
import '../../util/semantics.dart' as semantic;
import 'package:auto_size_text/auto_size_text.dart';

class DurationTypeValidator {
  static String? isRequired(String errMsg, bool isEmpty) {
    return (isEmpty) ? errMsg : null;
  }
}

class AddMedicalHistoryPage extends StatefulWidget {
  const AddMedicalHistoryPage({Key? key}) : super(key: key);

  @override
  _AddMedicalHistoryPageState createState() => _AddMedicalHistoryPageState();
}

class _AddMedicalHistoryPageState extends State<AddMedicalHistoryPage> {
  late TextEditingController _conditionsTextController;
  late TextEditingController _conditionDurationController;
  late GlobalKey<FormState> _formkey;
  late int _conditionDuration;
  late DurationType _conditionDurationType;
  late String _conditionName;
  late List<String> suggestions;

  _AddMedicalHistoryPageState();

  @override
  void initState() {
    _formkey = GlobalKey<FormState>();
    _conditionsTextController = TextEditingController();
    _conditionDurationController = TextEditingController();
    _conditionDuration = 0;
    _conditionName = "";
    _conditionsTextController.text = _conditionName;
    _conditionDurationController.text = _conditionDuration.toString();
    _conditionDurationType = DurationType.Day;
    suggestions = [];
    super.initState();
  }

  List<String> getDiseaseDict(String searchStr) {
    List<String> terms = GetIt.instance<DiaseaseGlossary>().words;

    terms.retainWhere((element) => element.contains(searchStr));

    print("terms" + terms.toString());
    return terms;
  }

  Widget buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          key: K.closeButton,
          icon: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(
                Foundation.x,
                size: UI.DIALOG_ACTION_BTN_SIZE,
              )),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      Container(
          alignment: Alignment.center,
          child: AutoSizeText(
              "  ${AppLocalizations.of(context)!.addMedicalHistory}",
              style: Theme.of(context).textTheme.titleLarge)),
      IconButton(
          key: K.checkButton,
          icon: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(Foundation.check,
                  size: UI.DIALOG_ACTION_BTN_SIZE,
                  semanticLabel: semantic.S.ADD_MEDICAL_HISTORY_DONE_BUTTON)),
          onPressed: () {
            if (_formkey.currentState!.validate()) {
              _formkey.currentState!.save();

              MedicalHistory medicalHistory = (MedicalHistory(
                  _conditionName, _conditionDuration, _conditionDurationType));
              Navigator.of(context).pop(medicalHistory);
            }
          })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        key: K.medicalHistorySlide,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        height: (MediaQuery.of(context).size.height * 3) / 4,
        width: MediaQuery.of(context).size.width,
        child: Form(
            key: _formkey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: buildHeader()),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 60,
                  child: Semantics(
                      identifier: semantic.S.ADD_MEDICAL_HISTORY_NAME,
                      child: TypeAheadField<String>(
                        key: K.medicalHistoryName,
                        direction: VerticalDirection.down,
                        controller: _conditionsTextController,
                        builder: (context, controller, focusNode) =>
                            TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontStyle: FontStyle.italic),
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            hintText: '',
                          ),
                          validator: (val) {
                            if (val?.isEmpty ?? true) {
                              return AppLocalizations.of(context)!.isRequired(
                                  AppLocalizations.of(context)!
                                      .preExistingConditions);
                            }
                            return null;
                          },
                          onSaved: (val) {
                            if (val?.isNotEmpty ?? true) {
                              _conditionName = val!;
                            }
                          },
                        ),
                        decorationBuilder: (context, child) => Material(
                          type: MaterialType.card,
                          elevation: 4,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          child: child,
                        ),
                        itemBuilder: (context, suggestion) => ListTile(
                          title: Text(suggestion),
                        ),
                        debounceDuration: const Duration(milliseconds: 400),
                        hideOnEmpty: true,
                        hideOnSelect: true,
                        hideOnUnfocus: true,
                        hideWithKeyboard: true,
                        retainOnLoading: false,
                        onSelected: (suggestion) {
                          _conditionsTextController.text = suggestion;
                        },
                        suggestionsCallback: (pattern) async {
                          if (pattern.isNotEmpty) {
                            return Future.sync(
                                () => getDiseaseDict(pattern.toLowerCase()));
                          } else {
                            return [];
                          }
                        },
                      )),
                ),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 70,
                    padding: const EdgeInsets.all(10),
                    child: Semantics(
                      identifier: semantic.S.ADD_MEDICAL_HISTORY_SINCE,
                      child: TextFormField(
                        key: K.durationField,
                        decoration: InputDecoration(
                            icon: const Icon(Icons.timelapse, size: 30),
                            labelText: AppLocalizations.of(context)!.duration,
                            border: const UnderlineInputBorder()),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: false),
                        controller: _conditionDurationController,
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: Validatorless.required(
                            AppLocalizations.of(context)!.isRequired(
                                AppLocalizations.of(context)!.duration)),
                        onSaved: (val) {
                          if (val?.isNotEmpty ?? true)
                            _conditionDuration = int.parse(val!);
                        },
                        enabled: true,
                      ),
                    )),
                Semantics(
                    container: true,
                    identifier: semantic
                        .S.ADD_MEDICAL_HISTORY_DURATION_DROPDOWN,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 60,
                        child: CustomDropdown<DurationType>.search(
                            hintText: AppLocalizations.of(context)!.duration,
                            key: K.durationTypeField,
                            decoration: CustomDropdownDecoration(
                                closedFillColor: Theme.of(context).primaryColor,
                                closedBorder: Border.all(color: Colors.black),
                                expandedFillColor: Theme.of(context)
                                    .primaryColor,
                                headerStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                                errorStyle: const TextStyle(fontSize: 10),
                                closedErrorBorder:
                                    Border.all(color: Colors.red)),
                            headerBuilder: (context, durationType,
                                displayHeader) {
                              return Container(
                                  padding: const EdgeInsets.all(3),
                                  color: Theme.of(context).primaryColor,
                                  child: AutoSizeText(
                                      EnumToString.convertToString(durationType,
                                              camelCase: true)
                                          .toLowerCase()));
                            },
                            validateOnChange: false,
                            validator: (val) =>
                                DurationTypeValidator.isRequired(
                                    AppLocalizations.of(context)!.isRequired(
                                        AppLocalizations.of(context)!.duration),
                                    (val == null)),
                            initialItem: _conditionDurationType,
                            listItemBuilder:
                                (context, durationType, selected, onTap) {
                              return Semantics(
                                  identifier:
                                      semantic.S.ADD_MEDICATION_UNIT_OPTION,
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(3),
                                      child: ListTile(
                                          title: AutoSizeText(
                                              EnumToString.convertToString(
                                                      durationType,
                                                      camelCase: true)
                                                  .toLowerCase()))));
                            },
                            items: DurationType.values.sublist(0, 4),
                            onChanged: (val) {
                              _conditionDurationType = val!;
                              setState(() {});
                            })))
              ]),
            ])));
  }
}
