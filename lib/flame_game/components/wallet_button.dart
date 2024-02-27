import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_wallet/google_wallet.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletButton extends StatefulWidget {
  const WalletButton({super.key});

  @override
  State<WalletButton> createState() => _WalletButtonState();
}

class _WalletButtonState extends State<WalletButton> {
  final googleWallet = GoogleWallet();
  final String jwt =
      'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJpc3MiOiJpc3N1ZXJAZXhhbXBsZS5jb20iLCJhdWQiOiJnb29nbGUiLCJ0eXAiOiJzYXZldG93YWxsZXQiLCJpYXQiOjE3MDc5NTI3MDAsIm9yaWdpbnMiOlsid3d3LmV4YW1wbGUuY29tIl0sInBheWxvYWQiOnsiZ2VuZXJpY09iamVjdHMiOlt7ImlkIjoiSVNTVUVSX0lELk9CSkVDVF9JRCIsImNsYXNzSWQiOiJJU1NVRVJfSUQuR0VORVJJQ19DTEFTU19JRCIsImxvZ28iOnsic291cmNlVXJpIjp7InVyaSI6Imh0dHBzOi8vc3RvcmFnZS5nb29nbGVhcGlzLmNvbS93YWxsZXQtbGFiLXRvb2xzLWNvZGVsYWItYXJ0aWZhY3RzLXB1YmxpYy9wYXNzX2dvb2dsZV9sb2dvLmpwZyJ9LCJjb250ZW50RGVzY3JpcHRpb24iOnsiZGVmYXVsdFZhbHVlIjp7Imxhbmd1YWdlIjoiZW4tVVMiLCJ2YWx1ZSI6IkxPR09fSU1BR0VfREVTQ1JJUFRJT04ifX19LCJjYXJkVGl0bGUiOnsiZGVmYXVsdFZhbHVlIjp7Imxhbmd1YWdlIjoiZW4tVVMiLCJ2YWx1ZSI6IltURVNUIE9OTFldIEdvb2dsZSBJL08ifX0sInN1YmhlYWRlciI6eyJkZWZhdWx0VmFsdWUiOnsibGFuZ3VhZ2UiOiJlbi1VUyIsInZhbHVlIjoiQXR0ZW5kZWUifX0sImhlYWRlciI6eyJkZWZhdWx0VmFsdWUiOnsibGFuZ3VhZ2UiOiJlbi1VUyIsInZhbHVlIjoiQWxleCBNY0phY29icyJ9fSwidGV4dE1vZHVsZXNEYXRhIjpbeyJpZCI6InBvaW50cyIsImhlYWRlciI6IlBPSU5UUyIsImJvZHkiOiIxMTEyIn0seyJpZCI6ImNvbnRhY3RzIiwiaGVhZGVyIjoiQ09OVEFDVFMiLCJib2R5IjoiNzkifV0sImJhcmNvZGUiOnsidHlwZSI6IlFSX0NPREUiLCJ2YWx1ZSI6IkJBUkNPREVfVkFMVUUiLCJhbHRlcm5hdGVUZXh0IjoiIn0sImhleEJhY2tncm91bmRDb2xvciI6IiM0Mjg1ZjQiLCJoZXJvSW1hZ2UiOnsic291cmNlVXJpIjp7InVyaSI6Imh0dHBzOi8vc3RvcmFnZS5nb29nbGVhcGlzLmNvbS93YWxsZXQtbGFiLXRvb2xzLWNvZGVsYWItYXJ0aWZhY3RzLXB1YmxpYy9nb29nbGUtaW8taGVyby1kZW1vLW9ubHkucG5nIn0sImNvbnRlbnREZXNjcmlwdGlvbiI6eyJkZWZhdWx0VmFsdWUiOnsibGFuZ3VhZ2UiOiJlbi1VUyIsInZhbHVlIjoiSEVST19JTUFHRV9ERVNDUklQVElPTiJ9fX19XX19.';
  bool? _available = false;
  String _text = 'Loading';

  @override
  void initState() {
    super.initState();
    _checkAvailable();
  }

  _checkAvailable() async {
    bool? available;
    String text;
    try {
      available = await googleWallet.isAvailable();
      text = "Google Wallet is available: $available";
    } on PlatformException catch (e) {
      text = "Error: '${e.message}'.";
    }

    setState(() {
      _available = available;
      _text = text;
    });
  }

  _savePass() async {
    bool? saved = false;
    String text;
    try {
      if (_available == true) {
        saved = await googleWallet.savePassesJwt(jwt);
        text = "Pass saved: $saved";
      } else {
        // Wallet unavailable,
        // fall back to saving pass via web
        await _savePassBrowser();
        text = "Opened Google Wallet via web";
      }
    } on PlatformException catch (e) {
      text = "Error: '${e.message}'.";
    }
    setState(() {
      _text = text;
    });
  }

  _savePassBrowser() async {
    String url = "https://pay.google.com/gp/v/save/$jwt";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not open Google Wallet via web';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GoogleWalletButton(
              style: GoogleWalletButtonStyle.condensed,
              height: 90,
              onPressed: _savePass,
            ),
            Text(_text),
          ],
        ),
      ),
    );
  }
}
