import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../util/semantics.dart' as semantic;
import '../../util/keys.dart';

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({Key? key}) : super(key: key);

  @override
  _AddNotesPageState createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  late String _notes;
  late TextEditingController _notesController;

  late ScrollController _notesScrollController;
  late FocusNode _notesFocusNode;

  @override
  void initState() {
    _notes = '';
    _notesController = TextEditingController();
    _notesFocusNode = FocusNode();
    _notesScrollController = ScrollController();
    super.initState();
  }

  Widget buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          key: K.addNote,
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
              " ${AppLocalizations.of(context)!.addNote}",
              style: Theme.of(context).textTheme.titleLarge,
              semanticsLabel: semantic.S.ADD_NOTES_TITLE)),
      IconButton(
          key: K.checkButton,
          icon: const Icon(Foundation.check,
              size: UI.DIALOG_ACTION_BTN_SIZE,
              semanticLabel: semantic.S.ADD_NOTE_DONE_BUTTON),
          onPressed: () {
            Navigator.of(context).pop(_notes);
          })
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.only(top: 10, bottom: 20, left: 15, right: 15),
        child: Stack(children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    alignment: Alignment.center,
                    child: buildHeader()),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Icon(FontAwesome.edit, size: 25),
                SizedBox(height: 5),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      border: Border(
                        top: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 0.5),
                        left: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 0.5),
                        right: BorderSide(
                            color: Theme.of(context).indicatorColor,
                            width: 0.5),
                      ),
                    ),
                    child: Scrollbar(
                        controller: _notesScrollController,
                        child: Semantics(
                            identifier: semantic.S.ADD_NOTE_FIELD,
                            child: TextField(
                              key: K.noteTextField,
                              focusNode: _notesFocusNode,
                              scrollController: _notesScrollController,
                              decoration: const InputDecoration(
                                  errorStyle:
                                      TextStyle(height: 0.5, fontSize: 8),
                                  labelText: " enter note here ",
                                  errorMaxLines: 1,
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.white),
                              controller: _notesController,
                              keyboardType: TextInputType.multiline,
                              minLines: 12,
                              maxLength: 150,
                              autofocus: false,
                              maxLines: 20,
                              onChanged: (val) {
                                _notes = val;
                                // print(_notes);
                              },
                              onSubmitted: (val) {
                                _notes = val;
                                // print(_notes);
                              },
                            ))))
              ])
        ]));
  }
}
