import 'package:ezscrip/consultation/model/testParameter.dart';
import 'package:ezscrip/consultation/model/testParametersGlossary.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:validatorless/validatorless.dart';
import '../../util/semantics.dart' as semantic;
import 'package:auto_size_text/auto_size_text.dart';

class AddParameterPage extends StatefulWidget {
  final List<TestParameter> parameterList;
  const AddParameterPage({required this.parameterList, Key? key})
      : super(key: key);

  @override
  _AddParameterPageState createState() => _AddParameterPageState();
}

class _AddParameterPageState extends State<AddParameterPage> {
  late TextEditingController _parameterNameController,
      _parameterValueController,
      _parameterUnitController;

  late GlobalKey<FormState> _formkey;

  late String _parameterName;
  late String _parameterValue;
  late String _parameterUnit;

  _AddParameterPageState();

  @override
  void initState() {
    _formkey = GlobalKey<FormState>();
    _parameterNameController = TextEditingController();
    _parameterValueController = TextEditingController();
    _parameterUnitController = TextEditingController();
    _parameterName = "";
    _parameterUnit = "";
    super.initState();
  }

  List<String> getTestParameterNames(String searchStr) {
    List<String> terms = GetIt.instance<TestParametersGlossary>().names;
    terms.retainWhere((element) =>
        (element.toLowerCase().startsWith(searchStr.toLowerCase()) ||
            element.toLowerCase().contains(searchStr.toLowerCase())));
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
              "${AppLocalizations.of(context)!.addParameter}",
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
              TestParameter newTestParameter = TestParameter(
                  _parameterName, _parameterValue, _parameterUnit);
              Navigator.of(context).pop(newTestParameter);
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
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: buildHeader()),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      alignment: Alignment.center,
                      child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.75,
                                height: 60,
                                child: Semantics(
                                    identifier:
                                        semantic.S.ADD_PARAMETER_NAME_FIELD,
                                    child: TypeAheadField<String>(
                                      key: K.parameterNameField,
                                      direction: VerticalDirection.down,
                                      controller: _parameterNameController,
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
                                                              .name);
                                                }
                                                return null;
                                              },
                                              onSaved: (suggestion) {
                                                _parameterName =
                                                    suggestion.toString();
                                                _parameterNameController.text =
                                                    _parameterName;
                                              }),
                                      decorationBuilder: (context, child) =>
                                          Material(
                                        type: MaterialType.card,
                                        elevation: 4,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        child: child,
                                      ),
                                      itemBuilder: (context, suggestion) =>
                                          ListTile(
                                        title: Text(suggestion),
                                      ),
                                      debounceDuration:
                                          const Duration(milliseconds: 400),
                                      hideOnSelect: true,
                                      hideOnEmpty: true,
                                      hideOnUnfocus: true,
                                      hideWithKeyboard: true,
                                      retainOnLoading: false,
                                      onSelected: (suggestion) {
                                        _parameterNameController.text =
                                            suggestion;
                                      },
                                      suggestionsCallback: (pattern) async {
                                        if (pattern.isNotEmpty) {
                                          return Future.sync(() =>
                                              getTestParameterNames(
                                                  pattern.toLowerCase()));
                                        }
                                        {
                                          return [];
                                        }
                                      },
                                    )),
                              )
                            ]),
                            Row(children: [
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  padding: const EdgeInsets.all(10),
                                  child: Semantics(
                                    identifier:
                                        semantic.S.ADD_PARAMETER_VALUE_FIELD,
                                    child: TextFormField(
                                      key: K.parameterValueField,
                                      decoration: InputDecoration(
                                          icon: SvgPicture.asset(
                                              Images.medicalTest,
                                              width: 25,
                                              height: 25),
                                          hintText: "Value",
                                          border: const UnderlineInputBorder()),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal:false),
                                      controller: _parameterValueController,
                                      autovalidateMode:
                                          AutovalidateMode.disabled,
                                      validator: Validatorless.required(
                                          AppLocalizations.of(context)!
                                              .isRequired(
                                                  AppLocalizations.of(context)!
                                                      .parameterValue)),
                                      onSaved: (val) {
                                        if (val?.isNotEmpty ?? true)
                                          _parameterValue = val!;
                                      },
                                      enabled: true,
                                    ),
                                  )),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  padding: const EdgeInsets.all(30),
                                  child: TextFormField(
                                    key: K.paramaeterUnitField,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      hintText: "Unit",
                                    ),
                                    controller: _parameterUnitController,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    // validator: Validatorless.required(
                                    //     AppLocalizations.of(context)!.isRequired(
                                    //         AppLocalizations.of(context)!.parameterUnit)),
                                    onSaved: (val) {
                                      if (val?.isNotEmpty ?? true)
                                        _parameterUnit = val!;
                                    },
                                    enabled: true,
                                  ))
                            ]),
                          ]))
                ])));
  }
}
