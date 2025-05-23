// ignore_for_file: unused_local_variable

import 'package:ezscrip/consultation/model/direction.dart';
import 'package:ezscrip/consultation/model/unit.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/consultation/model/indicator.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
import 'package:ezscrip/consultation/model/medschedule.dart';
import 'package:ezscrip/consultation/model/testParameter.dart';
import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/resources/resources.dart';
import '../../consultation/model/medStatus.dart';

class CustomBoxDecoration extends pw.BoxDecoration {
  @override
  void paint(
    pw.Context context,
    PdfRect box, [
    pw.PaintPhase phase = pw.PaintPhase.foreground,
  ]) {
    context.canvas
      ..setColor(PdfColors.red)
      ..setLineWidth(0.01)
      ..setLineCap(PdfLineCap.round)
      ..drawLine(box.left + 5, (box.top - box.height / 2), box.right - 5,
          (box.top - box.height / 2));
  }
}

class PrescriptionGenerator_2 {
  static pw.Widget buildSymptoms(
    List<String> symptoms,
    String symptomsSvg,
    String circleSvg,
    pw.Context context,
  ) {
    return (symptoms.isNotEmpty && symptoms.isNotEmpty)
        ? pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Container(
                  alignment: pw.Alignment.topLeft,
                  width: 150,
                  padding: const pw.EdgeInsets.all(5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                          bottom: pw.BorderSide(
                              width: 1.0, color: pdf.PdfColors.black))),
                  child: pw.Stack(
                    alignment: pw.Alignment.centerLeft,
                    children: [
                      pw.SvgImage(
                          svg: symptomsSvg,
                          height: 25,
                          width: 25,
                          clip: true,
                          fit: pw.BoxFit.contain),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 30),
                          child: pw.Text("Symptoms",
                              style: pw.Theme.of(context)
                                  .defaultTextStyle
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),
              ]),
              pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                    top: pw.BorderSide(width: 1.0, color: pdf.PdfColors.black),
                  )),
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Wrap(
                    spacing: 5.0,
                    runSpacing: 4.0,
                    children: symptoms
                        .map((symptom) => pw.Padding(
                            padding:
                                const pw.EdgeInsets.only(left: 5, right: 5),
                            child: pw.Stack(children: [
                              pw.SvgImage(
                                  svg: circleSvg,
                                  height: 10,
                                  width: 10,
                                  clip: true,
                                  fit: pw.BoxFit.contain),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 20),
                                  child: pw.Text(symptom,
                                      style: pw.Theme.of(context)
                                          .defaultTextStyle
                                          .copyWith(fontSize: 10)))
                            ])))
                        .toList(),
                  ))
            ]))
        : pw.Container();
  }

  static pw.Widget buildDateAndTimeHeaders(
      pw.Context context, DateTime consultationTime, Locale locale) {
    return pw.Container(
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.all(10),
        child: pw.Stack(children: [
          pw.Text(
              DateFormat.yMMMd(locale.languageCode).format(consultationTime),
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    fontSize: 12,
                  )),
          pw.Padding(
              padding: const pw.EdgeInsets.only(left: 100),
              child: pw.Text(
                  DateFormat.jm(locale.languageCode).format(consultationTime),
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontSize: 12,
                      )))
        ]));
  }

  static pw.Widget buildIndicators(List<Indicator> indicators,
      String indicatorsSvg, String circleSvg, pw.Context context) {
    List<pw.Stack> indicatorWidgets = [];

    if (indicators.isNotEmpty && indicators.isNotEmpty) {
      indicatorWidgets = indicators
          .map((indicator) =>
              pw.Stack(alignment: pw.Alignment.centerLeft, children: [
                pw.SvgImage(
                    svg: circleSvg,
                    height: 10,
                    width: 10,
                    clip: true,
                    fit: pw.BoxFit.contain),
                pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 15),
                    child: pw.Text(
                        overflow: pw.TextOverflow.clip,
                        "${indicator.getType().toString().substring(indicator.getType().toString().indexOf(".") + 1)}:${indicator.getValue()} ${indicator.getUnits()}"))
              ]))
          .toList();
    }
    return (indicators.isNotEmpty && indicators.isNotEmpty)
        ? pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Container(
                        width: 175,
                        padding: const pw.EdgeInsets.all(5),
                        alignment: pw.Alignment.topLeft,
                        decoration: const pw.BoxDecoration(
                            border: pw.Border(
                                bottom: pw.BorderSide(
                                    width: 1.0, color: pdf.PdfColors.black))),
                        child: pw.Stack(
                            alignment: pw.Alignment.centerLeft,
                            children: [
                              pw.SvgImage(
                                  svg: indicatorsSvg,
                                  height: 25,
                                  width: 25,
                                  clip: true,
                                  fit: pw.BoxFit.contain),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 30),
                                  child: pw.Text("Vitals",
                                      style: pw.Theme.of(context)
                                          .defaultTextStyle
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold))),
                            ]))
                  ]),
                  pw.Container(
                      padding: const pw.EdgeInsets.only(
                          top: 10, bottom: 10, left: 10, right: 5),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        top: pw.BorderSide(
                            width: 1.0, color: pdf.PdfColors.black),
                      )),
                      child: pw.Expanded(
                          child: pw.Wrap(
                              spacing: 30.0,
                              runSpacing: 10.0,
                              children: indicatorWidgets)))
                ]))
        : pw.Container();
  }

  static pw.Widget buildMedicalHistory(
    List<MedicalHistory> conditions,
    String conditionsSvg,
    String circleSvg,
    pw.Context context,
  ) {
    return (conditions.isNotEmpty && conditions.isNotEmpty)
        ? pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Column(children: [
              pw.Row(children: [
                pw.Container(
                    alignment: pw.Alignment.topLeft,
                    width: 150,
                    padding: const pw.EdgeInsets.all(5),
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 1.0, color: pdf.PdfColors.black))),
                    child:
                        pw.Stack(alignment: pw.Alignment.centerLeft, children: [
                      pw.SvgImage(
                          svg: conditionsSvg,
                          height: 25,
                          width: 25,
                          clip: true,
                          fit: pw.BoxFit.contain),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 30),
                        child: pw.Text("Medical History",
                            style:
                                pw.Theme.of(context).defaultTextStyle.copyWith(
                                      fontSize: 12,
                                    )),
                      )
                    ])),
              ]),
              pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  padding: const pw.EdgeInsets.all(5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                    top: pw.BorderSide(width: 1.0, color: pdf.PdfColors.black),
                  )),
                  child: pw.Wrap(
                      spacing: 5.0,
                      runSpacing: 10.0,
                      children: conditions
                          .map((condition) => pw.Padding(
                              padding:
                                  const pw.EdgeInsets.only(left: 5, right: 5),
                              child: pw.Stack(
                                  alignment: pw.Alignment.centerLeft,
                                  children: [
                                    pw.SvgImage(
                                        svg: circleSvg,
                                        height: 10,
                                        width: 10,
                                        clip: true,
                                        fit: pw.BoxFit.contain),
                                    pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 15),
                                        child: pw.Text(
                                            "${condition.getDiseaseName()} - ${condition.getDuration().toString()} ${EnumToString.convertToString(condition.getDurationType())}",
                                            style: const pw.TextStyle(
                                                fontSize: 10)))
                                  ])))
                          .toList()))
            ]))
        : pw.Container();
  }

  static pw.Widget buildTimes(
      List<Time> times, Map<String, String> timeIconMap) {
    List<pw.SvgImage> icons = [];

    times.forEach((element) {
      String? iconStr = timeIconMap[
          element.toString().substring(element.toString().indexOf(".") + 1)];
      pw.SvgImage widget = pw.SvgImage(svg: iconStr!, height: 15, width: 15);
      icons.add(widget);
    });

    return pw.Container(
        width: 70,
        child: pw.ListView(direction: pw.Axis.horizontal, children: icons));
  }

  static pw.Widget buildTimesLegend(
      List<Time> times, Map<String, String> timeIconMap) {
    List<pw.Container> icons = [];

    times.forEach((element) {
      String? iconStr = timeIconMap[
          element.toString().substring(element.toString().indexOf(".") + 1)];
      pw.SvgImage widget = pw.SvgImage(svg: iconStr!, height: 20, width: 20);
      icons.add(pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Stack(children: [
            widget,
            pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20),
                child: pw.Text(element.name.toString()))
          ])));
    });

    return pw.Container(
        width: 70,
        child: pw.ListView(direction: pw.Axis.horizontal, children: icons));
  }

  static pw.Widget buildMedicationSchedule(
    List<MedSchedule> medications,
    String prescriptionSvg,
    String lineSvg,
    Map<String, String> timeIconsMap,
    pw.Context context,
  ) {
    List<pw.TableRow> medicationList = medications.map((medication) {
      List<pw.Widget> row = [];

      if (medication.getStatus() != MedStatus.Discontinue) {
        // row.add(pw.Padding(
            // padding:
                // const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            // child: pw.SizedBox(
              // width: 30,
              // child: pw.Text(
                  // "${medication.dosage}${EnumToString.convertToString(medication.unit, camelCase: true).toLowerCase()}",
                  // style: pw.Theme.of(context).tableCell),
            // )));

        row.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            child: pw.SizedBox(
              width: 70,
              child: pw.Text(
                  "${medication.dosage} ${(medication.unit != Unit.tabs && medication.unit != Unit.caps) ? EnumToString.convertToString(medication.unit, camelCase: true).toLowerCase(): ""} ${medication.getName()}  (${EnumToString.convertToString(medication.getPreparation(),
                     camelCase: true)})",
                  style: pw.Theme.of(context).tableCell),
            )));

        // row.add(pw.Padding(
            // padding:
                // const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            // child: pw.SizedBox(
                // width: 65,
                // child: pw.Text(
                    // EnumToString.convertToString(medication.getPreparation(),
                        // camelCase: true),
                    // style: pw.Theme.of(context).tableCell))));

        row.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            child: pw.SizedBox(
                width: 65,
                child: pw.Text(
                    medication.frequencyType.toString().substring(
                        medication.frequencyType.toString().indexOf("_") + 1),
                    style: pw.Theme.of(context).tableCell))));

        row.add((buildTimes(medication.times!, timeIconsMap)));

        row.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            child: pw.SizedBox(
                width: 50,
                child: pw.Text(
                    "${medication.duration} ${EnumToString.convertToString(medication.durationType, camelCase: true)}",
                    style: pw.Theme.of(context).tableCell))));

        row.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            child: pw.Text(
                medication.direction != null &&
                        medication.direction != Direction.NotApplicable
                    ? EnumToString.convertToString(medication.direction,
                        camelCase: true)
                    : "",
                style: pw.Theme.of(context).tableCell)));
      } else {
        row.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            child: pw.Text(medication.getName(),
                style: pw.Theme.of(context).tableCell)));

        row.add(pw.Padding(
            padding:
                const pw.EdgeInsets.only(left: 0, top: 5, bottom: 5, right: 0),
            child: pw.Text(
                EnumToString.convertToString(medication.getPreparation(),
                    camelCase: true),
                style: pw.Theme.of(context).tableCell)));
      }
      return (medication.getStatus() != MedStatus.Discontinue)
          ? pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: row)
          : pw.TableRow(decoration: CustomBoxDecoration(), children: row);
    }).toList();

    List<pw.TableRow> rows = [];
    rows.add(pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        decoration: const pw.BoxDecoration(
            border: pw.Border(
                top: pw.BorderSide(width: 2.0),
                bottom: pw.BorderSide(width: 2.0))),
        children: [
          // pw.SizedBox(
          // width: 35,
          // child: pw.Padding(
          // padding: const pw.EdgeInsets.only(
          // left: 0, top: 5, bottom: 5, right: 2),
          // child: pw.Text('Unit',
          // style: pw.Theme.of(context).tableHeader))),
          pw.SizedBox(
              width: 150,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(
                      left: 0, top: 5, bottom: 5, right: 2),
                  child: pw.Text('Drug Name',
                      style: pw.Theme.of(context).tableHeader))),
          // pw.SizedBox(
          // width: 65,
          // child: pw.Padding(
          // padding: const pw.EdgeInsets.only(
          // left: 0, top: 5, bottom: 5, right: 2),
          // child: pw.Text('Preparation',
          // style: pw.Theme.of(context).tableHeader),
          //)),
          pw.SizedBox(
              width: 65,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(
                    left: 0, top: 5, bottom: 5, right: 2),
                child: pw.Text('Frequency',
                    style: pw.Theme.of(context).tableHeader),
              )),
          pw.SizedBox(
              width: 65,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(
                    left: 0, top: 5, bottom: 5, right: 2),
                child: pw.Text('Time', style: pw.Theme.of(context).tableHeader),
              )),
          pw.SizedBox(
              width: 50,
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(
                    left: 0, top: 5, bottom: 5, right: 2),
                child: pw.Text('Duration',
                    style: pw.Theme.of(context).tableHeader),
              )),
          pw.SizedBox(
              width: 50,
              child: pw.Padding(
                  padding: const pw.EdgeInsets.only(
                      left: 0, top: 5, bottom: 5, right: 2),
                  child: pw.Text('Advice',
                      style: pw.Theme.of(context).tableHeader))),
        ]));

    rows.addAll(medicationList);

    Map<int, pw.FixedColumnWidth> columnWidths = {};

    columnWidths.putIfAbsent(0, () => const pw.FixedColumnWidth(150));
    // columnWidths.putIfAbsent(2, () => const pw.FixedColumnWidth(75));
    columnWidths.putIfAbsent(1, () => const pw.FixedColumnWidth(65));
    columnWidths.putIfAbsent(2, () => const pw.FixedColumnWidth(65));
    columnWidths.putIfAbsent(3, () => const pw.FixedColumnWidth(65));
    columnWidths.putIfAbsent(4, () => const pw.FixedColumnWidth(50));
    // columnWidths.putIfAbsent(5, () => const pw.FixedColumnWidth(50));

    return pw.Container(
        alignment: pw.Alignment.topLeft,
        padding: const pw.EdgeInsets.all(5),
        child: pw.Stack(alignment: pw.Alignment.topCenter, children: [
          pw.Row(children: [
            pw.SvgImage(
                svg: prescriptionSvg,
                height: 25,
                width: 25,
                clip: true,
                fit: pw.BoxFit.contain),
          ]),
          pw.Container(
              margin: const pw.EdgeInsets.only(top: 5),
              padding: const pw.EdgeInsets.only(top: 30),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Table(
                        columnWidths: columnWidths,
                        border: const pw.TableBorder(
                          top: pw.BorderSide(width: 2.0),
                          bottom: pw.BorderSide(width: 2.0),
                          // left: pw.BorderSide(width: 2.0),
                          // right: pw.BorderSide(width: 2.0)
                        ),
                        defaultVerticalAlignment:
                            pw.TableCellVerticalAlignment.top,
                        children: rows),
                    buildTimesLegend(Time.values, timeIconsMap),
                  ]))
        ]));
  }

  static pw.Widget buildPatientSummary(
      pw.Context context, Consultation consultation, String patientSvg) {
    return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        child: pw.Column(children: [
          pw.Row(children: [
            pw.Container(
              alignment: pw.Alignment.topLeft,
              width: 150,
              padding: const pw.EdgeInsets.all(5),
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(
                          width: 1.0, color: pdf.PdfColors.black))),
              child: pw.Stack(
                alignment: pw.Alignment.centerLeft,
                children: [
                  pw.SvgImage(
                      svg: patientSvg,
                      height: 25,
                      width: 25,
                      clip: true,
                      fit: pw.BoxFit.contain),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 30),
                      child: pw.Text("Patient",
                          style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontSize: 14, fontWeight: pw.FontWeight.bold))),
                ],
              ),
            ),
          ]),
          pw.Container(
              alignment: pw.Alignment.topLeft,
              padding: const pw.EdgeInsets.all(5),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("${consultation.getPatientName()}",
                        style: pw.Theme.of(context).header5),
                    pw.Text(
                        "${consultation.getPatientAge().toString()} years",
                        style: pw.Theme.of(context).header5),
                    pw.Text(
                        "${EnumToString.convertToString(consultation.getGender(), camelCase: false)}",
                        style: pw.Theme.of(context).header5),
                    pw.Text(
                       "${consultation.getWeight().toString()} kg",
                      style: pw.Theme.of(context).header5,
                    )
                  ]))
        ]));
  }

  static pw.Widget buildHeader(
      pw.Context context, AppUser user, String clinicIcon, String phoneIcon,
      {String? defaultIcon}) {
    return (context.pageNumber == 1)
        ? pw.Container(
            height: 60,
            alignment: pw.Alignment.bottomLeft,
            margin: const pw.EdgeInsets.only(
                bottom: 0.0 * pdf.PdfPageFormat.mm,
                top: 1.0 * pdf.PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(
                left: 2.0 * pdf.PdfPageFormat.mm,
                right: 2.0 * pdf.PdfPageFormat.mm,
                bottom: 2.0 * pdf.PdfPageFormat.mm,
                top: 0.0 * pdf.PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom:
                        pw.BorderSide(width: 2.0, color: pdf.PdfColors.black))),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                      alignment: pw.Alignment.bottomCenter,
                      child: pw
                          .Stack(alignment: pw.Alignment.centerLeft, children: [
                        (defaultIcon != null)
                            ? pw.SvgImage(
                                svg: defaultIcon, height: 50, width: 50)
                            : pw.SizedBox(height: 10, width: 10),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 60),
                          child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.end,
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                    "${user.getFirstName()} ${user.getLastName()}",
                                    style: pw.Theme.of(context)
                                        .header2
                                        .copyWith(color: pdf.PdfColors.grey)),
                                pw.Text(user.getCredentials(),
                                    style: pw.Theme.of(context)
                                        .header1
                                        .copyWith(color: pdf.PdfColors.grey)),
                                pw.Text(user.getSpecialization(),
                                    style: pw.Theme.of(context)
                                        .header2
                                        .copyWith(color: pdf.PdfColors.grey)),
                              ]),
                        )
                      ])),
                  pw.Container(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            child: pw.Stack(
                                alignment: pw.Alignment.centerLeft,
                                children: [
                                  pw.SvgImage(
                                      svg: clinicIcon, height: 20, width: 20),
                                  pw.Padding(
                                      padding:
                                          const pw.EdgeInsets.only(left: 30),
                                      child: pw.Text(user.getClinic(),
                                          style: pw.Theme.of(context)
                                              .header4
                                              .copyWith(
                                                  color: pdf.PdfColors.grey)))
                                ]),
                          ),
                          pw.Container(
                              child: pw.Stack(
                                  alignment: pw.Alignment.centerLeft,
                                  children: [
                                pw.SvgImage(
                                    svg: phoneIcon, height: 20, width: 20),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(left: 25),
                                    child: pw.Text(user.getContactNo(),
                                        style: pw.Theme.of(context)
                                            .header4
                                            .copyWith(
                                                color: pdf.PdfColors.grey))),
                              ]))
                        ]),
                  )
                ]))
        : pw.SizedBox(height: 1);
  }

  static pw.Widget buildSignature(String signatureSvg) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
      pw.SvgImage(
          svg: signatureSvg.trim(),
          height: 50,
          width: 100,
          clip: true,
          fit: pw.BoxFit.contain),
    ]);
  }

  static pw.Widget buildFooter(
      pw.Context context, bool isSignatureSet, String? signatureSvg) {
    pw.Widget pageNumberRow = pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [pw.Text("${context.pageNumber} / ${context.pagesCount}")]);

    return pw.Container(
        child: (isSignatureSet && context.pageNumber == context.pagesCount)
            ? pw.Stack(alignment: pw.Alignment.topCenter, children: [
                buildSignature(signatureSvg!),
                pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 50),
                    child: pageNumberRow)
              ])
            : pageNumberRow);
  }

  static int calculateInitialBlockLength(
      Consultation consultation, bool isSignatureSet) {
    int weight = 3;
    int initial = 10;

    if (consultation.getSymptoms().length > 5) weight += 1;

    if ((consultation.indicators.isNotEmpty &&
            consultation.indicators.length > 2) ||
        consultation.getMedicalHistory().length > 5) weight += 1;

    weight += consultation.getNotes().length;

    if (initial - weight <= 0) {
      initial = 0;
    } else {
      initial = initial - weight;
    }

    // print("initial:" + initial.toString());

    return (initial > consultation.prescription.length)
        ? consultation.prescription.length
        : initial;
  }

  static List<pw.Widget> buildMedscheduleBlock(
      Consultation consultation,
      String prescriptionSvg,
      String lineSvg,
      Map<String, String> timeIconsMap,
      bool isSignatureSet,
      pw.Context context) {
    List<pw.Widget> medscheduleBlocks = [];

    int index = 0;
    int initial = calculateInitialBlockLength(consultation, isSignatureSet);

    if (initial > 0 && consultation.prescription.length > initial) {
      medscheduleBlocks.add(pw.SizedBox(height: 10));
      medscheduleBlocks.add(buildMedicationSchedule(
          consultation.prescription.sublist(index, initial),
          prescriptionSvg,
          lineSvg,
          timeIconsMap,
          context));

      index += initial;
    }

    while (index < consultation.prescription.length) {
      if ((index + 8) < consultation.prescription.length) {
        medscheduleBlocks.add(pw.SizedBox(height: 10));
        medscheduleBlocks.add(buildMedicationSchedule(
            consultation.prescription.sublist(index, index + 8),
            prescriptionSvg,
            lineSvg,
            timeIconsMap,
            context));

        index += 8;
      } else {
        medscheduleBlocks.add(pw.SizedBox(height: 10));
        medscheduleBlocks.add(buildMedicationSchedule(
            consultation.prescription.sublist(index),
            prescriptionSvg,
            lineSvg,
            timeIconsMap,
            context));
        index = consultation.prescription.length;
      }
    }

    return medscheduleBlocks;
  }

  static pw.Widget buildTestParameters(List<TestParameter> testParameters,
      String testParametersSvg, String circleSvg, pw.Context context) {
    List<pw.Padding> parametersWidget = [];

    return (testParameters.isNotEmpty)
        ? pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    pw.Container(
                        width: 150,
                        padding: const pw.EdgeInsets.all(5),
                        alignment: pw.Alignment.topLeft,
                        child: pw.Stack(
                            alignment: pw.Alignment.centerLeft,
                            children: [
                              pw.SvgImage(
                                  svg: testParametersSvg,
                                  height: 25,
                                  width: 25,
                                  clip: true,
                                  fit: pw.BoxFit.contain),
                              pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 30),
                                  child: pw.Text("Parameters",
                                      style: pw.Theme.of(context)
                                          .defaultTextStyle
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold))),
                            ]))
                  ]),
                  pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      padding: const pw.EdgeInsets.all(5),
                      decoration: const pw.BoxDecoration(
                          border: pw.Border(
                        top: pw.BorderSide(
                            width: 1.0, color: pdf.PdfColors.black),
                      )),
                      child: pw.Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: testParameters
                              .map((parameter) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 5, right: 5),
                                  child: pw.Stack(
                                      alignment: pw.Alignment.centerLeft,
                                      children: [
                                        pw.SvgImage(
                                            svg: circleSvg,
                                            height: 10,
                                            width: 10,
                                            clip: true,
                                            fit: pw.BoxFit.contain),
                                        pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                                left: 15),
                                            child: pw.Text(
                                                "${parameter.getName()} - ${parameter.getValue()} ${(parameter.getUnit() != null) ? parameter.getUnit() : ""}",
                                                style: const pw.TextStyle(
                                                    fontSize: 10)))
                                      ])))
                              .toList()))
                ]))
        : pw.Container();
  }

  static pw.Widget buildTestsWidget(Consultation consultation, String testsIcon,
      String circleSvg, pw.Context context) {
    return (consultation.getTests().isNotEmpty)
        ? pw.Container(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Stack(alignment: pw.Alignment.topCenter, children: [
              pw.Row(children: [
                pw.Container(
                  alignment: pw.Alignment.topLeft,
                  width: 150,
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Stack(
                    alignment: pw.Alignment.centerLeft,
                    children: [
                      pw.SvgImage(
                          svg: testsIcon,
                          height: 25,
                          width: 25,
                          // clip: true,
                          fit: pw.BoxFit.contain),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 30),
                          child: pw.Text("Tests",
                              style: pw.Theme.of(context)
                                  .defaultTextStyle
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                ),
              ]),
              pw.Container(
                  margin: const pw.EdgeInsets.only(top: 40, bottom: 10),
                  padding: const pw.EdgeInsets.only(top: 10),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                    top: pw.BorderSide(width: 1.0, color: pdf.PdfColors.black),
                  )),
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Row(children: [
                    pw.Wrap(
                      spacing: 5.0,
                      runSpacing: 4.0,
                      children: consultation
                          .getTests()
                          .map((test) => pw.Padding(
                              padding:
                                  const pw.EdgeInsets.only(left: 5, right: 5),
                              child: pw.Stack(children: [
                                pw.SvgImage(
                                    svg: circleSvg,
                                    height: 10,
                                    width: 10,
                                    clip: true,
                                    fit: pw.BoxFit.contain),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(left: 20),
                                    child: pw.Text(test,
                                        style: pw.Theme.of(context)
                                            .defaultTextStyle
                                            .copyWith(fontSize: 10)))
                              ])))
                          .toList(),
                    )
                  ]))
            ]))
        : pw.Container();
  }

  static pw.Widget buildNotesWidget(
      Consultation consultation, String notesIcon) {
    List<pw.TableRow> notesList = consultation
        .getNotes()
        .map((note) => pw.TableRow(children: [
              pw.Paragraph(text: note, style: const pw.TextStyle(fontSize: 10))
            ]))
        .toList();
    return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        alignment: pw.Alignment.centerLeft,
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    width: 150,
                    decoration: const pw.BoxDecoration(
                        border: pw.Border(
                            bottom: pw.BorderSide(
                                width: 1.0, color: pdf.PdfColors.black))),
                    child:
                        pw.Stack(alignment: pw.Alignment.centerLeft, children: [
                      pw.SvgImage(
                          svg: notesIcon,
                          height: 20,
                          width: 20,
                          clip: true,
                          fit: pw.BoxFit.contain),
                      pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 40),
                          child: pw.Text("Notes"))
                    ]))
              ]),
              pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: const pw.BoxDecoration(
                      border: pw.Border(
                    top: pw.BorderSide(width: 1.0, color: pdf.PdfColors.black),
                  )),
                  child: pw.Table(children: notesList))
            ]));
  }

  static int parametersBlockLength(List<TestParameter> testParameter) {
    return (testParameter.isNotEmpty) ? (testParameter.length / 3).ceil() : 0;
  }

  static int testsBlockLength(List<String> tests) {
    return (tests.isNotEmpty) ? (tests.length / 3).ceil() : 0;
  }

  static int notesBlockLength(List<String> notes) {
    return (notes.isNotEmpty) ? notes.length : 0;
  }

  static Future<pw.Document> buildPrescription(
      Consultation consultation,
      AppUser user,
      Locale locale,
      Uint8List byteData,
      bool isSignatureSet,
      Map<String, String> timeIconsMap,
      [String? signatureSvg]) async {
    pw.Document document = pw.Document();
    pw.PageTheme pageTheme;

    final String circleSvg = await rootBundle.loadString(Images.circle);

    final String personSvg = await rootBundle.loadString(Images.person);

    final String symptomsSvg = await rootBundle.loadString(Images.humanBody);
    final String conditionsSvg =
        await rootBundle.loadString(Images.medicalHistory2);
    final String indicatorsSvg = await rootBundle.loadString(Images.vitalSigns);
    final String prescriptionSvg =
        await rootBundle.loadString(Images.prescription);

    final String testsSvg = await rootBundle.loadString(Images.tests);

    final String notesSvg = await rootBundle.loadString(Images.noteSticky);

    final String clinicSvg = await rootBundle.loadString(Images.clinic);

    final String phoneSvg = await rootBundle.loadString(Images.phone);

    final String testParametersSvg =
        await rootBundle.loadString(Images.medicalTest);

    final String icon = (await GetIt.instance<UtilsService>()
            .loadSpecialities())
        .firstWhere((element) => element.getTitle() == user.getSpecialization())
        .getIcon();

    final String lineSvg = await rootBundle.loadString(Images.line);

    final String iconData = await rootBundle.loadString(icon);

    //pageTheme = await _getPageTheme(
    //     pdf.PdfPageFormat.a4, user, byteData, 0.5, 0, 0.25, 0);

    List<pw.Widget> firstPageBlocks = [];
    List<pw.Widget> secondPageBlocks = [];

    List<int> firstPageBlockLengths = [];
    List<int> secondPageBlockLengths = [];

    int currentLength = 2;

    pageTheme = await _getPageTheme(
        pdf.PdfPageFormat.a4, user, byteData, 0.5, 1.0, 0.5, 0.5);

    document.addPage(
        index: 0,
        pw.MultiPage(
            pageTheme: pageTheme,
            header: (pw.Context context) {
              return buildHeader(context, user, clinicSvg, phoneSvg,
                  defaultIcon: iconData);
            },
            footer: (pw.Context context) =>
                buildFooter(context, isSignatureSet, signatureSvg),
            build: (pw.Context context) {
              firstPageBlocks.add(
                buildDateAndTimeHeaders(
                    context, consultation.getStart(), locale),
              );

              firstPageBlocks.add(pw.Partitions(children: [
                pw.Partition(
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        buildPatientSummary(context, consultation, personSvg),
                        pw.SizedBox(height: 5),
                        buildMedicalHistory(consultation.getMedicalHistory(),
                            conditionsSvg, circleSvg, context)
                      ]),
                ),
                pw.Partition(
                    child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                      buildIndicators(consultation.indicators, indicatorsSvg,
                          circleSvg, context),
                      pw.SizedBox(height: 5),
                      buildSymptoms(consultation.getSymptoms(), symptomsSvg,
                          circleSvg, context),
                    ]))
              ]));

              if (consultation.getParameters().isNotEmpty) {
                currentLength +=
                    parametersBlockLength(consultation.getParameters());

                pw.Widget pageBlock = buildTestParameters(
                    consultation.getParameters(),
                    testParametersSvg,
                    circleSvg,
                    context);

                if (currentLength <=
                    GlobalConfiguration()
                        .getValue(C.PRESCRIPTION_BLOCK_LENGTH)) {
                  firstPageBlocks.add(pageBlock);
                } else {
                  secondPageBlocks.add(pageBlock);
                }
              }

              if (consultation.getNotes().isNotEmpty) {
                currentLength +=
                    parametersBlockLength(consultation.getParameters());

                pw.Widget pageBlock = buildNotesWidget(consultation, notesSvg);

                if (currentLength <=
                    GlobalConfiguration()
                        .getValue(C.PRESCRIPTION_BLOCK_LENGTH)) {
                  firstPageBlocks.add(pageBlock);
                } else {
                  secondPageBlocks.add(pageBlock);
                }
              }

              if (consultation.getTests().isNotEmpty) {
                currentLength += testsBlockLength(consultation.getTests());

                pw.Widget pageBlock = buildTestsWidget(
                    consultation, testsSvg, circleSvg, context);

                if (currentLength <=
                    GlobalConfiguration()
                        .getValue(C.PRESCRIPTION_BLOCK_LENGTH)) {
                  firstPageBlocks.add(pageBlock);
                } else {
                  secondPageBlocks.add(pageBlock);
                }
              }

              int availableLength = (currentLength <
                      GlobalConfiguration()
                          .getValue(C.PRESCRIPTION_BLOCK_LENGTH))
                  ? (GlobalConfiguration()
                          .getValue(C.PRESCRIPTION_BLOCK_LENGTH) -
                      currentLength)
                  : 0;

              pw.Widget pageWidget;

              if (availableLength > 0) {
                if (consultation.prescription.length > availableLength) {
                  pageWidget = buildMedicationSchedule(
                      consultation.prescription.sublist(0, availableLength),
                      prescriptionSvg,
                      lineSvg,
                      timeIconsMap,
                      context);
                } else {
                  pageWidget = buildMedicationSchedule(
                      consultation.prescription,
                      prescriptionSvg,
                      lineSvg,
                      timeIconsMap,
                      context);
                }

                firstPageBlocks.add(pageWidget);

                if (consultation.prescription.length - availableLength > 0) {
                  pageWidget = buildMedicationSchedule(
                      consultation.prescription.sublist(
                          (consultation.prescription.length - availableLength) +
                              1),
                      prescriptionSvg,
                      lineSvg,
                      timeIconsMap,
                      context);

                  secondPageBlocks.add(pageWidget);
                }
              } else {
                pageWidget = buildMedicationSchedule(consultation.prescription,
                    prescriptionSvg, lineSvg, timeIconsMap, context);
                secondPageBlocks.add(pageWidget);
              }

              return firstPageBlocks;
            }));

    document.addPage(
        index: 1,
        pw.MultiPage(
            pageTheme: pageTheme,
            footer: (pw.Context context) =>
                buildFooter(context, isSignatureSet, signatureSvg),
            build: (pw.Context context) {
              print("secondPageBlockLengths :" +
                  secondPageBlockLengths.toString());
              return secondPageBlocks;
            }));

    return document;
  }

  static Future<pw.PageTheme> _getPageTheme(
      pdf.PdfPageFormat format,
      AppUser user,
      Uint8List backgroundImage,
      double left,
      double top,
      double right,
      double bottom) async {
    format =
        format.applyMargin(left: left, top: top, right: right, bottom: bottom);

    {
      return pw.PageTheme(
          pageFormat: format,
          orientation: pw.PageOrientation.portrait,
          textDirection: pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(
            base: pw.Font.courier(),
            bold: pw.Font.courierBold(),
          ),
          buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(
                margin: const pw.EdgeInsets.only(left: 30, right: 5),
                child: pw.Positioned(
                  top: 0,
                  left: 0,
                  child: pw.Image(pw.MemoryImage(
                    backgroundImage,
                  )),
                ),
              )));
    }
  }
}
