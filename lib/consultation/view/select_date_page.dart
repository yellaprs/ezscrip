import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import '../../util/keys.dart';

class SelectDatePage extends StatefulWidget {
  final DateTime selectedDate;
  late DateTime? initialDate;

  SelectDatePage({required this.selectedDate, this.initialDate, Key? key})
      : super(key: key);

  @override
  _SelectDatePageState createState() =>
      _SelectDatePageState(this.selectedDate, this.initialDate);
}

class _SelectDatePageState extends State<SelectDatePage> {
  DateTime selectedDate;

  DateTime? initialDate;

  _SelectDatePageState(this.selectedDate, this.initialDate);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.35,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        child: Container(
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 10,
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                key: K.cancelButton,
                                icon: const Icon(Icons.close,
                                    size: UI.DIALOG_ACTION_BTN_SIZE),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            Container(
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                    " ${AppLocalizations.of(context)!.select}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge)),
                            IconButton(
                                key: K.checkButton,
                                icon: const Icon(Foundation.check,
                                    size: UI.DIALOG_ACTION_BTN_SIZE),
                                onPressed: () {
                                  Navigator.of(context).pop(selectedDate);
                                })
                          ])),
                  Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: DatePickerWidget(
                          key: K.dateSelectionSlider,
                          looping: false, // default is not looping
                          firstDate: (initialDate != null)
                              ? initialDate
                              : DateTime(1900, 1, 1),
                          lastDate: DateTime(DateTime.now().year, 12, 31, 23,
                              59), //DateTime(1960)
                          initialDate: selectedDate, // DateTime(1994),
                          dateFormat: "dd-MMM-yyyy",
                          pickerTheme: DateTimePickerTheme(
                            pickerHeight:
                                MediaQuery.of(context).size.height * 0.2,
                            itemTextStyle:
                                Theme.of(context).textTheme.displaySmall!,
                            itemHeight:
                                MediaQuery.of(context).size.height * 0.06,
                            dividerColor: Colors.grey[100],
                          ),
                          onChange: (value, indexes) {
                            setState(() {
                              selectedDate = value;
                            });
                          },
                          onCancel: () {},
                          onConfirm: (value, indexe) {
                            setState(() {
                              selectedDate = value;
                            });
                          }))
                ])));
  }
}
