import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:ezscrip/consultation/model/medStatus.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:validatorless/validatorless.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/focus_nodes.dart';
import '../../util/keys.dart';
import '../model/medschedule.dart';
import '../model/preparation.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;

class PreparationFilter with CustomDropdownListFilter {
  final Preparation preparation;

  const PreparationFilter(this.preparation);

  @override
  String toString() {
    return preparation.toString();
  }

  @override
  bool filter(String query) {
    return EnumToString.convertToString(preparation)
        .toLowerCase()
        .contains(query.replaceAll(RegExp(r"\s+\b|\b\s"), "").toLowerCase());
  }
}

class RemoveMedicationPage extends StatefulWidget {
  const RemoveMedicationPage({Key? key}) : super(key: key);

  @override
  _RemoveMedicationPageState createState() => _RemoveMedicationPageState();
}

class _RemoveMedicationPageState extends State<RemoveMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _medicineController;
  late Preparation _preparation;
  late String _medName;

  @override
  initState() {
    _medicineController = TextEditingController();
    _medicineController.text = "";
    _preparation = Preparation.Capsule;
    super.initState();
  }

  Widget buildMedNameWidget() {
    return TextFormField(
        key: K.medicationNameAutoSizeTextField,
        focusNode: FocusNodes.medicationNameAutoSizeTextField,
        readOnly: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
            errorMaxLines: 2,
            errorStyle: const TextStyle(height: 1, fontSize: 8),
            errorBorder: const UnderlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderSide: BorderSide(color: Colors.red, width: 1.0),
            ),
            border: UnderlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(9)),
            labelText:
                "${AppLocalizations.of(context)!.drug} ${AppLocalizations.of(context)!.name} (e.g. paracetmol)",
            labelStyle: Theme.of(context).textTheme.bodyMedium),
        controller: _medicineController,
        validator: Validatorless.multiple([
          Validatorless.max(30,
              "${AppLocalizations.of(context)!.drug} ${AppLocalizations.of(context)!.name}"),
          Validatorless.required(AppLocalizations.of(context)!.isRequired(
              "${AppLocalizations.of(context)!.drug} ${AppLocalizations.of(context)!.name}"))
        ]),
        onChanged: (val) {
          _medName = val;
        },
        onSaved: (val) {
          _medName = val!;
        });
  }

  Widget getPreparationIcon(Preparation preparation) {
    Widget icon = const Icon(Fontisto.pills, size: 20);

    switch (preparation) {
      case Preparation.Capsule:
        icon = const Icon(MaterialCommunityIcons.pill, size: 15);
        break;
      case Preparation.Tablet:
        icon = const Icon(MaterialCommunityIcons.pill, size: 15);
        break;
      case Preparation.InjectionIm:
        icon = const Icon(Fontisto.injection_syringe, size: 15);
        break;
      case Preparation.InjectionIv:
        icon = const Icon(Fontisto.injection_syringe, size: 15);
        break;
      case Preparation.EarDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 15);
        break;
      case Preparation.EyeDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 15);
        break;
      case Preparation.NasalDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 20);
        break;
      case Preparation.Ointment:
        icon = SvgPicture.asset(Images.ointment, height: 15, width: 15);
        break;
      case Preparation.OralSyrup:
        icon = const Icon(MaterialCommunityIcons.bottle_tonic_plus, size: 20);
        break;
    }
    return icon;
  }

  Widget buildRouteWidget(Orientation orientation) {
    return Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.175,
        width: MediaQuery.of(context).size.width * 0.6,
        alignment: Alignment.center,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: Stack(alignment: Alignment.topLeft, children: [
          Text(
            AppLocalizations.of(context)!.preparation,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Focus(
                  focusNode: FocusNodes.routeDropDown,
                  child: Semantics(
                      label:
                          semantic.S.ADD_MEDICATION_DRUG_PREPARATION_DROPDOWN,
                      container: true,
                      child: CustomDropdown<PreparationFilter>.search(
                        key: K.routeDropDown,
                        hintText: AppLocalizations.of(context)!.preparation,
                        excludeSelected: false,
                        decoration: CustomDropdownDecoration(
                            closedFillColor: Theme.of(context).primaryColor,
                            closedBorder: Border.all(color: Colors.black),
                            expandedFillColor: Theme.of(context).primaryColor,
                            headerStyle: Theme.of(context).textTheme.titleSmall,
                            errorStyle: const TextStyle(fontSize: 10),
                            closedErrorBorder: Border.all(color: Colors.red)),
                        headerBuilder: (context, preparation, displayHeader) {
                          return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                getPreparationIcon(preparation.preparation),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 5),
                                    child: Text(EnumToString.convertToString(
                                            preparation.preparation,
                                            camelCase: true)
                                        .toLowerCase()))
                              ]);
                        },
                        items: Preparation.values
                            .map((e) => PreparationFilter(e))
                            .toList(),
                        listItemBuilder:
                            (context, preparation, selected, onTap) {
                          return ListTile(
                              leading:
                                  getPreparationIcon(preparation.preparation),
                              title: Text(EnumToString.convertToString(
                                      preparation.preparation,
                                      camelCase: true)
                                  .toLowerCase()));
                        },
                        onChanged: (val) {
                          _preparation = val!.preparation;
                          setState(() {});
                        },
                      ))))
        ]));
  }
  // Widget buildRouteWidget(Orientation orientation) {
  //   return Container(
  //       padding: const EdgeInsets.all(10),
  //       constraints:
  //           BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
  //       child: Focus(
  //           focusNode: FocusNodes.routeDropDown,
  //           child: Semantics(
  //               identifier: semantic.S.ADD_MEDICATION_DRUG_PREPARATION_DROPDOWN,
  //               container: true,
  //               child: CustomDropdown<PreparationFilter>.search(
  //                 key: K.routeDropDown,
  //                 hintText: AppLocalizations.of(context)!.preparation,
  //                 excludeSelected: false,
  //                 decoration: CustomDropdownDecoration(
  //                     closedFillColor: Theme.of(context).primaryColor,
  //                     closedBorder: Border.all(color: Colors.black),
  //                     expandedFillColor: Theme.of(context).primaryColor,
  //                     headerStyle: Theme.of(context).textTheme.titleSmall,
  //                     closedErrorBorder: Border.all(color: Colors.red)),
  //                 headerBuilder: (context, preparation) {
  //                   return Stack(alignment: Alignment.centerLeft, children: [
  //                     getPreparationIcon(preparation.preparation),
  //                     Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 30, vertical: 5),
  //                         child: Text(EnumToString.convertToString(
  //                                 preparation.preparation,
  //                                 camelCase: true)
  //                             .toLowerCase()))
  //                   ]);
  //                 },
  //                 items: Preparation.values
  //                     .map((e) => PreparationFilter(e))
  //                     .toList(),
  //                 listItemBuilder: (context, preparation, selected, onTap) {
  //                   return Semantics(
  //                       identifier:
  //                           semantic.S.ADD_MEDICATION_PREPARATION_OPTION,
  //                       child: ListTile(
  //                           leading:
  //                               getPreparationIcon(preparation.preparation),
  //                           title: Text(EnumToString.convertToString(
  //                                   preparation.preparation,
  //                                   camelCase: true)
  //                               .toLowerCase())));
  //                 },
  //                 onChanged: (val) {
  //                   _preparation = val!.preparation;
  //                   setState(() {});
  //                 },
  //               ))));
  // }

  Widget buildHeader(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          icon: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(
                Icons.close,
                size: UI.DIALOG_ACTION_BTN_SIZE,
              )),
          onPressed: () {
            Navigator.of(context).pop();
          }),
      Container(
          alignment: Alignment.center,
          child: AutoSizeText(
              " ${AppLocalizations.of(context)!.stop} ${AppLocalizations.of(context)!.medication}",
              style: Theme.of(context).textTheme.titleLarge,
              semanticsLabel: semantic.S.ADD_MEDICATION_DRUG_TITLE)),
      IconButton(
        key: K.checkButton,
        icon: IconTheme(
          data: Theme.of(context).iconTheme,
          child: const Icon(
            Foundation.check,
            size: UI.DIALOG_ACTION_BTN_SIZE,
          ),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            MedSchedule removeMedication =
                MedSchedule(_medName, MedStatus.Discontinue, _preparation);
            navService.goBack(result: removeMedication);
            // Navigator.pop(context, removeMedication);
          }
        },
      )
    ]);
  }

  Widget buildPrescInfoHeader() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.0),
              right: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.0),
              left: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.0)),
        ),
        height: 50,
        width: MediaQuery.of(context).size.height * 0.15,
        child: Semantics(
          container: true,
          identifier: semantic.S.ADD_MEDICATION_DRUG_TITLE,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Theme.of(context).primaryColor,
              child: Stack(alignment: Alignment.centerLeft, children: [
                const Icon(MaterialCommunityIcons.pill,
                    size: 25, color: Colors.black),
                Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: AutoSizeText(AppLocalizations.of(context)!.drug,
                        style: Theme.of(context).textTheme.titleLarge))
              ])),
          //state: (_currentPageIndex == 0) ? StepState.editing : StepState.indexed,
          // isActive: (_currentPageIndex == 0) ? true : false,
        ));
  }

  Widget prescInfo() {
    return Container(
        key: K.drugInfoSlide,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(5),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPrescInfoHeader(),
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0)),
                      border: Border(
                        top: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 0.5),
                        left: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 1.5),
                        right: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 1.5),
                        bottom: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 1.5),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                child: buildMedNameWidget(),
                              ),
                              buildRouteWidget(Orientation.portrait)
                            ]))),
              )
            ])
      );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(2),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width - 5,
                  height: 80,
                  alignment: Alignment.center,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: buildHeader(context)),
              Expanded(child: prescInfo())
            ]),
      );
    });
  }
}
