import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import './util/semantics.dart' as semantic;

class AppBarBuilder {
  static Widget buildLeadingNavWidget(BuildContext context) {
    return IconButton(
        key: K.backNavButton,
        focusNode: FocusNodes.backNavButton,
        icon: IconTheme(
            data: Theme.of(context).iconTheme,
            child: const Icon(FontAwesome.chevron_left,
                semanticLabel: semantic.S.BACK_BTN)),
        onPressed: () async {
          navService.goBack();
        });
  }

  static PreferredSizeWidget buildAppBar(
      BuildContext context, String title, List<Widget> actions,
      [Widget leftNavAction = const SizedBox(width: 20, height: 20)]) {
    List<Widget> paddingWidgets = [];
    if (actions.isEmpty) {
      paddingWidgets.add(SizedBox(height: 25, width: 35, child: Container()));
      paddingWidgets.add(SizedBox(height: 25, width: 35, child: Container()));
    }
    return PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          leading: (ModalRoute.of(context)!.canPop)
              ? Container(
                  margin: (MediaQuery.of(context).orientation ==
                          Orientation.portrait)
                      ? const EdgeInsets.all(8)
                      : const EdgeInsets.all(6),
                  child: buildLeadingNavWidget(context))
              : leftNavAction,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(8), child: SizedBox(height: 8)),
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading:
              (ModalRoute.of(context)!.settings.name == "/Home") ? false : true,
          title: Center(
              child: AutoSizeText(
            title,
            style: Theme.of(context).textTheme.displayMedium,
            semanticsLabel: title,
          )),
          actions: (actions.isEmpty)
              ? paddingWidgets
              : [
                  ButtonBar(
                      alignment: MainAxisAlignment.center,
                      buttonPadding: const EdgeInsets.all(6),
                      children: actions)
                ],
        ));
  }
}
