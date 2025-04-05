import 'package:ezscrip/main.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:hand_signature/signature.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

import '../../app_bar.dart';
import '../../util/focus_nodes.dart';
import '../../util/mode.dart';

enum SignatureState { View, Sign }

class SignaturePage extends StatefulWidget {
  final bool _isSignatureEnabled;
  final Mode _mode;
  String? signatureSvg;

  SignaturePage(this._isSignatureEnabled, this._mode,
      {signatureSvg = "", Key? key})
      : super(key: key);

  @override
  _SignaturePageState createState() =>
      _SignaturePageState(_isSignatureEnabled, _mode, signatureSvg);
}

class _SignaturePageState extends State<SignaturePage> {
  Mode _mode;
  bool _isSignatureEnabled;

  String? _signatureSvg, _updatedSignatureSvg;

  late SignatureState state;

  HandSignatureControl control = HandSignatureControl(
    threshold: 0.01,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  _SignaturePageState(this._isSignatureEnabled, this._mode, this._signatureSvg);

  @override
  void initState() {
    state = SignatureState.View;
    _updatedSignatureSvg = _signatureSvg;

    super.initState();
  }

  List<IconButton> buildActions() {
    List<IconButton> IconButtons = [];
    IconButtons.add(IconButton(
      icon: Icon(
        Foundation.check,
        color: Theme.of(context).indicatorColor,
      ),
      focusNode: FocusNodes.saveSignatureSettings,
      onPressed: () async {
        if (_isSignatureEnabled) {
          await GetIt.instance<UserPrefs>().setSignatureEnabled(true);

          if (_signatureSvg != _updatedSignatureSvg) {
            await GetIt.instance<UserPrefs>()
                .setSignature(_updatedSignatureSvg!);
          }
        }

        navService.goBack();
        //Navigator.pop(context);
      },
    ));

    return IconButtons;
  }

  Widget buildSignaturePad() {
    return Expanded(
        child: Center(
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: AspectRatio(
              aspectRatio: 2.0,
              child: Stack(children: [
                Container(
                  constraints: const BoxConstraints.expand(),
                  //color: Colors.white,
                  child: HandSignature(
                    control: control,
                    width: 1.0,
                    type: SignatureDrawType.line,
                  ),
                ),
                CustomPaint(
                  painter: DebugSignaturePainterCP(
                    control: control,
                    cp: false,
                    cpStart: false,
                    cpEnd: false,
                  ),
                ),
              ]),
            )));
  }

  Widget buildSignatureWidget() {
    return (_signatureSvg != null)
        ? SvgPicture.string(
            (_signatureSvg!.trim() == _updatedSignatureSvg!.trim())
                ? _updatedSignatureSvg!
                : _signatureSvg!,
            height: 150,
            width: 300)
        : const SizedBox(height: 200, child: Text("Signature not found"));
  }

  List<IconButton> buildSignatureActions() {
    List<IconButton> actions = [];

    if (state == SignatureState.Sign) {
      actions.add(IconButton(
        onPressed: () {
          setState(() {
            state = SignatureState.View;
          });
        },
        icon: Icon(FontAwesome5Solid.chevron_circle_left,
            size: 25, color: Theme.of(context).indicatorColor),
      ));
      actions.add(IconButton(
        onPressed: () {
          control.clear();
        },
        icon: Icon(FontAwesome5Solid.eraser,
            size: 25, color: Theme.of(context).indicatorColor),
      ));
      actions.add(IconButton(
          icon: Icon(Icons.check,
              size: 25, color: Theme.of(context).indicatorColor),
          onPressed: () {
            _updatedSignatureSvg = control.toSvg();

            setState(() {
              state = SignatureState.View;
            });
          }));
    } else {
      actions.add(IconButton(
          onPressed: () {
            state = SignatureState.Sign;

            setState(() {});
          },
          icon: Icon(MaterialCommunityIcons.draw_pen,
              size: 25, color: Theme.of(context).indicatorColor)));
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context, AppLocalizations.of(context)!.signature, buildActions()),
        body: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height - 100,
            width: MediaQuery.of(context).size.width - 50,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(10),
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
            child: Column(children: <Widget>[
              Stack(alignment: Alignment.centerLeft, children: [
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("enable prescription signature ? ",
                            style: Theme.of(context).textTheme.titleLarge),
                        Focus(
                          focusNode: FocusNodes.enableSignature,
                          child: Switch(
                            value: _isSignatureEnabled,
                            onChanged: (val) {
                              setState(() {
                                _isSignatureEnabled = val;
                              });
                            },
                          ),
                        )
                      ]),
                ),
              ]),
              Expanded(
                  child: (_isSignatureEnabled)
                      ? Center(
                          child: Focus(
                              focusNode: FocusNodes.showSignaturePad,
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(13.0)),
                                  child: Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2,
                                      color: Colors.white,
                                      child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            (state == SignatureState.View)
                                                ? buildSignatureWidget()
                                                : buildSignaturePad(),
                                            Align(
                                                alignment: Alignment.topRight,
                                                child: ButtonBar(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    buttonMinWidth: 25,
                                                    buttonHeight: 35,
                                                    children:
                                                        buildSignatureActions())),
                                          ])))))
                      : Container())
            ])));
  }
}
