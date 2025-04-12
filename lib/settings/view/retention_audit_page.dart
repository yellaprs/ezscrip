import 'package:ezscrip/app_bar.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/settings/model/rentention_audit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timeline/flutter_timeline.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';

class RetentionAuditPage extends StatefulWidget {
  final RetentionTaskList _retentionAuditLog;
  const RetentionAuditPage(this._retentionAuditLog,
      {Key? key = K.retentionAuditPage})
      : super(key: key);

  @override
  _RetentionAuditPageState createState() =>
      _RetentionAuditPageState(this._retentionAuditLog);
}

class _RetentionAuditPageState extends State<RetentionAuditPage> {
  final RetentionTaskList _retentionAuditLog;

  _RetentionAuditPageState(this._retentionAuditLog);

  List<IconButton> buildActions() {
    List<IconButton> actions = [];
    actions.add(IconButton(
      key: K.saveButton,
      icon: IconTheme(
          data: Theme.of(context).iconTheme,
          child: const Icon(Foundation.save)),
      onPressed: () {},
    ));
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context, 
            const Icon(Icons.ac_unit, size:25),
            "Data Retention Log", 
            buildActions()),
        body: Container(
            height: MediaQuery.of(context).size.height - 30,
            width: MediaQuery.of(context).size.width - 20,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(1),
                    offset: const Offset(0, 30),
                    blurRadius: 3,
                    spreadRadius: -10)
              ],
            ),
            child: (_retentionAuditLog.retentionTasks != null)
                ? Timeline(
                    events: (_retentionAuditLog.retentionTasks.map((entry) =>
                        TimelineEventDisplay(
                            indicator: Container(
                                height: 40,
                                color: Colors.amber,
                                child: AutoSizeText(DateFormat.yMMMM(
                                        Localizations.localeOf(context)
                                            .languageCode)
                                    .format(entry.getTaskDate()))),
                            child: SizedBox(
                              height: 40,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoSizeText(entry.getCount().toString()),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {})
                                  ]),
                            )))).toList())
                : Center(
                    child: AutoSizeText(" No Log entries",
                        style: Theme.of(context).textTheme.displayMedium))));
  }
}
