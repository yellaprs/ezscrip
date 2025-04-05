import 'dart:io';
import 'package:ezscrip/consultation/consultation_routes.dart';
import 'package:ezscrip/consultation/model/consultation_model.dart';
import 'package:ezscrip/consultation/model/status.dart';
import 'package:ezscrip/prescription/prescription_routes.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/prescription/services/prescription_generator_1.dart';
import 'package:ezscrip/prescription/services/prescription_generator_2.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;
import 'package:ezscrip/util/utils_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:jiffy/jiffy.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:watch_it/watch_it.dart';

class DaytileBuilder extends WatchingStatefulWidget {
  final DateTime date;

  const DaytileBuilder(this.date);

  @override
  _DaytileBuilderState createState() => _DaytileBuilderState(this.date);
}

class _DaytileBuilderState extends State<DaytileBuilder> {
  DateTime date;

  _DaytileBuilderState(this.date);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Consultation> consultationList = watch(di<ConsultationModel>())
        .consultationMap[DateFormat('ddMMMyyyy').format(date)]!;

    return TimelineTile(
        axis: TimelineAxis.vertical,
        alignment: TimelineAlign.manual,
        lineXY: 0.2,
        beforeLineStyle: const LineStyle(color: Colors.grey, thickness: 3.0),
        afterLineStyle: const LineStyle(color: Colors.grey, thickness: 3.0),
        hasIndicator: true,
        indicatorStyle: IndicatorStyle(
          color: getIndicatorColor(date, consultationList.isEmpty, context),
          indicatorXY: 0.5,
          drawGap: true,
          indicator: buildDayViewHeaderLeading(
              date, consultationList.isEmpty, context),
        ),
        startChild: Container(
            alignment: Alignment.center,
            width: 35,
            height: 25,
            child: AutoSizeText(
                DateFormat.E(GetIt.instance<LocaleModel>().getLocale.languageCode)
                    .format(date),
                key: Key(
                    DateFormat.E(GetIt.instance<LocaleModel>().getLocale.languageCode)
                        .format(date)),
                style: TextStyle(
                    fontSize: 10, color: getTextColor(date, true, context)))),
        endChild: (consultationList.isNotEmpty)
            ? Container(
                key: Key(DateFormat('ddMMMyyyy').format(date)),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.brown[100]!, width: 1.0),
                        bottom:
                            BorderSide(color: Colors.brown[100]!, width: 1.0))),
                constraints: BoxConstraints(
                  minWidth: (50 * consultationList.length + 1).toDouble() + 5,
                  maxWidth: (50 * consultationList.length + 1).toDouble() + 5,
                ),
                child: Column(
                    children: consultationList
                        .map((consultation) => _eventBuilder(consultation, context))
                        .toList()))
            : SizedBox(
                height: 50,
                child: (DateTime.now().difference(date).inHours < 24 &&
                        DateTime.now().difference(date).inHours > 0)
                    ? Flex(
                        direction: Axis.horizontal,
                        children: List.generate(
                            (MediaQuery.of(context).size.width / 10).floor() -
                                10, (_) {
                          return SizedBox(
                            width: 10,
                            height: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.grey),
                            ),
                          );
                        }))
                    : Container(),
              ));
  }

  Color getBorderColor(DateTime date) {
    Color color;

    if (date.isAfter(DateTime.now())) {
      color = Colors.grey[500]!;
    } else {
      color = Colors.black;
    }

    return color;
  }

  Widget buildDayViewHeaderLeading(
      DateTime date, bool isEmpty, BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: getBorderColor(date), width: 1.0),
          color: Colors.yellow,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(0.75),
        child: Semantics(
            identifier:
                "${DateFormat.d(Localizations.localeOf(context).languageCode)}",
            child: CircleAvatar(
                key: Key(DateFormat('dd').format(date)),
                radius: 15,
                backgroundColor: getIndicatorColor(date, isEmpty, context),
                child: AutoSizeText(
                    DateFormat.d(Localizations.localeOf(context).languageCode)
                        .format(date),
                    key: K.selectedDateLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: getTextColor(date, false, context))))));
  }

  Color getTextColor(DateTime date, bool isLeading, BuildContext context) {
    Color color;
    DateTime today = DateTime.now();
    if (date.isBefore(DateTime(today.year, today.month, 1)) ||
        date.isAfter(DateTime(
            today.year,
            today.month,
            Jiffy.parse(DateFormat('ddMMMyyyy').format(today),
                    pattern: 'ddMMMyyyy')
                .daysInMonth,
            23,
            59))) {
      color = Colors.black;
    } else if (DateFormat("ddMMMyyyy").format(date) ==
        DateFormat("ddMMMyyyy").format(DateTime.now())) {
      color = (isLeading) ? Colors.red : Colors.white;
    } else if (date.isAfter(DateTime.now())) {
      color = Colors.grey[400]!;
    } else {
      color = Theme.of(context).primaryColorDark.withOpacity(1.0);
    }

    return color;
  }

  Color getIndicatorColor(DateTime date, bool isEmpty, BuildContext context) {
    Color color;
    DateTime today = DateTime.now();
    if (DateFormat("ddMMMyyyy").format(date) ==
        DateFormat("ddMMMyyyy").format(today)) {
      color = Colors.red;
    } else if (isEmpty) {
      color = Colors.white;
    } else if (date.isAfter(today)) {
      color = Colors.grey[100]!;
    } else {
      color = Theme.of(context).primaryColor;
    }

    return color;
  }


  Widget _eventBuilder(Consultation consultation, BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            side: const BorderSide(width: 0.5, color: Colors.brown),
            borderRadius: BorderRadius.circular(5)),
        elevation: 2,
        child: Slidable(
            key: Key("${consultation.getPatientName()}Slidable"),
            dragStartBehavior: DragStartBehavior.start,
            startActionPane: ActionPane(
              extentRatio: 0.5,
              motion: const StretchMotion(),
              children: buildEventActions(consultation, context),
            ),
            child: Builder(
                builder: (BuildContext context) => Container(
                      color: Theme.of(context).primaryColor,
                      height: 60,
                      width: MediaQuery.of(context).size.width - 80,
                      child: ListTile(
                        key: Key(
                            "consultationTile${consultation.getPatientName()}"),
                        contentPadding: const EdgeInsets.all(2),
                        onTap: () {
                          final controller = Slidable.of(context);

                          (controller?.actionPaneType.value ==
                                  ActionPaneType.none)
                              ? controller?.openStartActionPane(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.decelerate)
                              : controller?.close();
                        },
                        leading: SizedBox(
                            width: 90,
                            child: Stack(children: [
                              Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  alignment: Alignment.center,
                                  width: 80,
                                  child: AutoSizeText(DateFormat.jm(
                                          Localizations.localeOf(context)
                                              .languageCode)
                                      .format(consultation.getStart()))),
                            ])),
                        title: AutoSizeText(consultation.getPatientName(),
                            style: Theme.of(context).textTheme.titleMedium,
                            softWrap: true),
                      ),
                    ))));
  }

  List<CustomSlidableAction> buildEventActions(
      Consultation consultation, BuildContext context) {
    List<CustomSlidableAction> actions = [];

    if ((consultation.getStatus() == Status.Active ||
        (consultation.getStatus() == Status.InProgress))) {
      actions
          .add(buildEditConsultationAction(consultation, Mode.Edit, context));
      actions.add(buildDeleteConsultation(consultation, context));
    } else if (consultation.getStatus() == Status.Complete) {
      actions.add(buildViewPrecriptionAction(consultation, context));
      actions.add(buildViewConsultationAction(consultation, context));
    }

    return actions;
  }

  CustomSlidableAction buildViewPrecriptionAction(
      Consultation consultation, BuildContext context) {
    return CustomSlidableAction(
      key: Key("${consultation.id.toString()}viewPrescription"),
      autoClose: true,
      padding: const EdgeInsets.all(2),
      backgroundColor: Theme.of(context).indicatorColor,
      child: SizedBox(
          width: 85,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(FontAwesome5Solid.file_prescription, size: 20),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.prescription,
                    semanticsLabel: semantic.S.HOME_VIEW_PRESCRIPTION_BUTTON,
                    softWrap: false,
                    minFontSize: 4,
                    maxFontSize: 8,
                  ),
                ),
              ])),
      onPressed: (context) async {
        pw.Document prescPdf;
        String? letterHead;
        Uint8List byteData;
        String? signatureSvg;
        String? format;

        Map<String, String> timeIconsMap =
            await GetIt.instance<UtilsService>().getTimeIconMap();

        int prescriptionBlockLength =
            GlobalConfiguration().get(C.PRESCRIPTION_BLOCK_LENGTH) as int;

        int prescriptionBlockWeight =
            GlobalConfiguration().get(C.PRESCRIPTION_BLOCK_WEIGHT) as int;

        AppUser user = await GetIt.instance<UserPrefs>().getUser();

        letterHead = await GetIt.instance<UserPrefs>().getTemplate();
        format = await GetIt.instance<UserPrefs>().getFormat();

        byteData = (await rootBundle.load(letterHead!)).buffer.asUint8List();

        bool isPrescriptionSet =
            await GetIt.instance<UserPrefs>().isSignatureEnabled();
        Locale locale = GetIt.instance<LocaleModel>().getLocale;

        if (isPrescriptionSet) {
          signatureSvg = await GetIt.instance<UserPrefs>().getSignature();
        }
        if (format!.toLowerCase().contains(C.PRESCRIPTION_FORMAT_1)) {
          prescPdf = await PrescriptionGenerator_1.buildPrescription(
              consultation,
              user,
              locale,
              byteData,
              isPrescriptionSet,
              timeIconsMap,
              prescriptionBlockLength,
              prescriptionBlockWeight,
              signatureSvg);
        } else {
          prescPdf = await PrescriptionGenerator_2.buildPrescription(
              consultation,
              user,
              locale,
              byteData,
              isPrescriptionSet,
              timeIconsMap,
              signatureSvg);
        }

        String path = (await getApplicationCacheDirectory()).path;

        File prescFile =
            await File("${path}/${consultation.id.toString()}prescription.pdf")
                .create();
        Uint8List fileBytes = (await prescPdf.save());
        prescFile.writeAsBytesSync(fileBytes);

        navService.pushNamed(Routes.ViewPrescription,
            args: PrescriptionPdfViewPageArguments(
                generatedFile: prescFile.path,
                mode: Mode.View,
                status: consultation.getStatus()));

      },
    );
  }

  CustomSlidableAction buildViewConsultationAction(
      Consultation consultation, BuildContext context) {
    return CustomSlidableAction(
      key: Key("${consultation.id.toString()}viewConsultation"),
      backgroundColor: Theme.of(context).indicatorColor,
      padding: const EdgeInsets.all(2),
      autoClose: true,
      child: SizedBox(
          width: 85,
          child: Stack(alignment: Alignment.topCenter, children: [
            const Icon(FontAwesome5Solid.notes_medical, size: 20),
            Padding(
                padding: EdgeInsets.only(top: 30, left: 2, right: 2, bottom: 2),
                child: AutoSizeText(AppLocalizations.of(context)!.view,
                    semanticsLabel: semantic.S.HOME_VIEW_CONSULTATION_BUTTON,
                    minFontSize: 8,
                    maxFontSize: 10,
                    softWrap: true)),
          ])),
      onPressed: (context) async {
        AppUser user =  await GetIt.instance<UserPrefs>().getUser();
        navService.pushNamed(Routes.ViewConsultation,
            args: ConsultationPageArguments(consultation: consultation, user: user, isEditable: false));
      },
    );
  }

  CustomSlidableAction buildEditConsultationAction(
      Consultation consultation, Mode mode, BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).indicatorColor,
      autoClose: true,
      padding: const EdgeInsets.all(2),
      key: Key("${consultation.id.toString()}editConsultation"),
      onPressed: (context) async {
        AppUser user = await GetIt.instance<UserPrefs>().getUser();
        Map<String, dynamic> propertiesMap =
            await GetIt.instance<UtilsService>().loadProperties();
        navService.pushNamed(Routes.EditConsultation,
            args: ConsultationEditPageArguments(
                mode: mode,
                consultation: consultation,
                user: user,
                propertiesMap: propertiesMap));
      },
      child: SizedBox(
          width: 50,
          child: Stack(alignment: Alignment.topCenter, children: [
            const Icon(Icons.edit, size: 25),
            Padding(
              padding:
                  const EdgeInsets.only(top: 30, left: 2, right: 2, bottom: 2),
              child: AutoSizeText(AppLocalizations.of(context)!.edit,
                  semanticsLabel: semantic.S.HOME_EDIT_CONSULTATION_BUTTON,
                  minFontSize: 6,
                  maxFontSize: 10,
                  softWrap: true),
            ),
          ])),
    );
  }

  CustomSlidableAction buildDeleteConsultation(
      Consultation consultation, BuildContext context) {
    return CustomSlidableAction(
        autoClose: true,
        padding: const EdgeInsets.all(2),
        backgroundColor: Theme.of(context).indicatorColor,
        key: Key('${consultation.id}deleteConsultation'),
        child: SizedBox(
          width: 60,
          child: Stack(alignment: Alignment.topCenter, children: [
            const Icon(Icons.delete, size: 25),
            Padding(
              padding:
                  const EdgeInsets.only(top: 30, left: 2, right: 2, bottom: 2),
              child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.delete,
                    minFontSize: 6,
                  )),
            )
          ]),
        ),
        onPressed: (context) async {
          int deletedId =
              await GetIt.instance<ConsultationModel>().delete(consultation);
          if (deletedId > -1) setState(() {});
        });
  }
}
