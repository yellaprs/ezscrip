import 'package:ezscrip/consultation/model/status.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:io';
import 'package:share_it/share_it.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:ezscrip/applicationexception.dart';

import 'package:ezscrip/app_bar.dart';
// import 'package:pdf_encryption/pdf_encryption.dart' as pdfEncrypt;

class PrescriptionPdfViewPage extends StatefulWidget {
  final String generatedFile;
  final Mode mode;
  final Status status;

  const PrescriptionPdfViewPage(
      {required this.generatedFile,
      required this.mode,
      required this.status,
      Key key = K.prescriptionPreviewPage})
      : super(key: key);

  _PrescriptionPdfViewPageState createState() =>
      _PrescriptionPdfViewPageState(this.generatedFile, this.mode, this.status);
}

class _PrescriptionPdfViewPageState extends State<PrescriptionPdfViewPage>
    with WidgetsBindingObserver {
  final String _generatedFile;
  final Mode _mode;
  final Status _status;
  late bool _isReady;
  late String _errorMessage;

  _PrescriptionPdfViewPageState(this._generatedFile, this._mode, this._status);

  void initState() {
    super.initState();
    _errorMessage = "";
    _isReady = false;
  }

  List<IconButton> buildAppBarActions() {
    List<IconButton> actions = [];

    actions.add(IconButton(
        key: K.shareButon,
        focusNode: FocusNodes.sharButton,
        icon: const Icon(Icons.share_outlined, size: 30),
        color: Theme.of(context).iconTheme.color,
        onPressed: () async {
          // String encryptedPdfFile =
          //     (await getApplicationSupportDirectory()).path +
          //         "/" +
          //         consultation.patientName +
          //         "prescription.pdf";

          // encryptedPdfFile = await pdfEncrypt.PdfEncryption.encrypt(
          //     generatedFile,
          //     encryptedPdfFile,
          //     "password",
          //     consultation.patientName +
          //         DateFormat("ddMMyyyy").format(consultation.start));

          // if (File(encryptedPdfFile).existsSync()) File(generatedFile).delete();

          if (_mode != Mode.Preview) {
            try {
              await ShareIt.file(
                  path: _generatedFile, type: ShareItFileType.anyFile);
            } on PlatformException catch (exception) {
              throw ApplicationException(
                  "Platform Exception", "could not open file");
            }
          }
        }));

    actions.add(IconButton(
        key: K.printButton,
        focusNode: FocusNodes.prinButton,
        icon: const Icon(Icons.print, size: 30),
        color: Theme.of(context).iconTheme.color,
        onPressed: () async {
          await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) async =>
                  (File(_generatedFile)).readAsBytesSync());
        }));

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context,
            AppLocalizations.of(context)!.prescription,
            (_status == Status.Complete) ? buildAppBarActions() : []),
        body: Container(
            height: MediaQuery.of(context).size.height - 10,
            child: Stack(children: <Widget>[
              Semantics(
                identifier: semantic.S.VIEW_PRESCRIPTION_VIEWER,
                container: true,
                child: PDFView(
                  key: K.pdfViewWidget,
                  filePath: _generatedFile,
                ),
              )
            ])));
  }
}
