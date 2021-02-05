import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

String nfcData = "";
String type = " ";
String holder = "Test";

class NfcAuthentication extends StatefulWidget {
  @override
  _NfcAuth createState() => _NfcAuth();
}

class _NfcAuth extends State<NfcAuthentication> {
  void start() async {
    readTag();
    setState(() {
      holder = nfcData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('kitAuth'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(holder),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text('Read'),
                onPressed: () async {
                  start();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void readTag() async {
  var availability = await FlutterNfcKit.nfcAvailability;
  if (availability != NFCAvailability.available) {
    nfcData = 'Nfc not available';
    print(nfcData);
  }
  var tag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));

  switch (tag.type) {
    case NFCTagType.iso7816:
      {
        type = "iso7816";
      }
      break;
    case NFCTagType.iso15693:
      {
        type = "iso15693";
      }
      break;
    case NFCTagType.iso18092:
      {
        type = "iso18092";
      }
      break;
    case NFCTagType.mifare_classic:
      {
        type = "mifare_classic";
      }
      break;
    case NFCTagType.mifare_desfire:
      {
        type = "mifare_desfire";
      }
      break;
    case NFCTagType.mifare_plus:
      {
        type = "mifare_plus";
      }
      break;
    case NFCTagType.mifare_ultralight:
      {
        type = "mifare_ultralight";
      }
      break;
    case NFCTagType.unknown:
      {
        type = "unknown";
      }
      break;
    default:
      {
        type = "null";
      }
      break;
  }
  nfcData = "ID:" +
      tag.id +
      "\n" +
      "Tag Type:" +
      type +
      "\n" +
      "Standard:" +
      tag.standard +
      "\n" +
      "Protocol info:" +
      tag.protocolInfo +
      "\n" +
      "NDEF available? " +
      tag.ndefAvailable.toString() +
      "\n" +
      "NDEF type:" +
      tag.ndefType +
      "\n" +
      "NDEF writable? " +
      tag.ndefWritable.toString() +
      "\n" +
      "Standard: " +
      tag.standard;
}
