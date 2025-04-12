import 'package:ezscrip/consultation/model/status.dart';
import 'package:ezscrip/util/mode.dart';

class PrescriptionPdfViewPageArguments {
  final String generatedFile;
  final Mode mode;
  final Status status;

  PrescriptionPdfViewPageArguments(
      {required this.generatedFile, required this.mode, required this.status});
}
 