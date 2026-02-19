/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:esc_pos_printer/src/enqueuer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart';
import './enums.dart';

/// Network Printer
class NetworkPrinter {
  NetworkPrinter(this._paperSize, this._profile, {int spaceBetweenRows = 5}) {
    _generator = Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
  }

  final PaperSize _paperSize;
  final CapabilityProfile _profile;
  late String _host;
  late int _port;
  late Generator _generator;
  late Socket _socket;

  int get port => _port;

  String get host => _host;

  PaperSize get paperSize => _paperSize;

  CapabilityProfile get profile => _profile;

  Future<PosPrintResult> connect(String host, {int port = 91000, Duration timeout = const Duration(seconds: 5)}) async {
    _host = host;
    _port = port;
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
      _socket.add(_generator.reset());
      return Future<PosPrintResult>.value(PosPrintResult.success);
    } catch (e) {
      return Future<PosPrintResult>.value(PosPrintResult.timeout);
    }
  }

  /// [delayMs]: milliseconds to wait after destroying the socket
  void disconnect({int? delayMs}) async {
    _socket.destroy();
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs), () => null);
    }
  }

  // ************************ Printer Commands ************************
  void reset() {
    _socket.add(_generator.reset());
  }

  Future<void> resetAsync() async {
    await enqueueWithDelay(() {
      reset();
    });
  }

  void text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
    int? maxCharsPerLine,
  }) {
    _socket.add(_generator.text(text, styles: styles, linesAfter: linesAfter, containsChinese: containsChinese, maxCharsPerLine: maxCharsPerLine));
  }

  Future<void> textAsync(
    String t, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
    int? maxCharsPerLine,
  }) async {
    await enqueueWithDelay(() {
      text(t, styles: styles, linesAfter: linesAfter, containsChinese: containsChinese, maxCharsPerLine: maxCharsPerLine);
    });
  }

  void setGlobalCodeTable(String codeTable) {
    _socket.add(_generator.setGlobalCodeTable(codeTable));
  }

  Future<void> setGlobalCodeTableAsync(String codeTable) async {
    await enqueueWithDelay(() {
      setGlobalCodeTable(codeTable);
    });
  }

  void setGlobalFont(PosFontType font, {int? maxCharsPerLine}) {
    _socket.add(_generator.setGlobalFont(font, maxCharsPerLine: maxCharsPerLine));
  }

  Future<void> setGlobalFontAsync(PosFontType font, {int? maxCharsPerLine}) async {
    await enqueueWithDelay(() {
      setGlobalFont(font, maxCharsPerLine: maxCharsPerLine);
    });
  }

  void setStyles(PosStyles styles, {bool isKanji = false}) {
    _socket.add(_generator.setStyles(styles, isKanji: isKanji));
  }

  Future<void> setStylesAsync(PosStyles styles, {bool isKanji = false}) async {
    await enqueueWithDelay(() {
      setStyles(styles, isKanji: isKanji);
    });
  }

  void rawBytes(List<int> cmd, {bool isKanji = false}) {
    _socket.add(_generator.rawBytes(cmd, isKanji: isKanji));
  }

  Future<void> rawBytesAsync(List<int> cmd, {bool isKanji = false}) async {
    await enqueueWithDelay(() {
      rawBytes(cmd, isKanji: isKanji);
    });
  }

  void emptyLines(int n) {
    _socket.add(_generator.emptyLines(n));
  }

  Future<void> emptyLinesAsync(int n) async {
    await enqueueWithDelay(() {
      emptyLines(n);
    });
  }

  void feed(int n) {
    _socket.add(_generator.feed(n));
  }

  Future<void> feedAsync(int n) async {
    await enqueueWithDelay(() {
      feed(n);
    });
  }

  void cut({PosCutMode mode = PosCutMode.full}) {
    _socket.add(_generator.cut(mode: mode));
  }

  Future<void> cutAsync({PosCutMode mode = PosCutMode.full}) async {
    await enqueueWithDelay(() {
      cut(mode: mode);
    });
  }

  void printCodeTable({String? codeTable}) {
    _socket.add(_generator.printCodeTable(codeTable: codeTable));
  }

  Future<void> printCodeTableAwait({String? codeTable}) async {
    await enqueueWithDelay(() {
      printCodeTable(codeTable: codeTable);
    });
  }

  void beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    _socket.add(_generator.beep(n: n, duration: duration));
  }

  Future<void> beepAsync({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) async {
    await enqueueWithDelay(() {
      beep(n: n, duration: duration);
    });
  }

  void reverseFeed(int n) {
    _socket.add(_generator.reverseFeed(n));
  }

  Future<void> reverseFeedAsync(int n) async {
    await enqueueWithDelay(() {
      reverseFeed(n);
    });
  }

  void row(List<PosColumn> cols) {
    _socket.add(_generator.row(cols));
  }

  Future<void> rowAsync(List<PosColumn> cols) async {
    await enqueueWithDelay(() {
      row(cols);
    });
  }

  void image(Image imgSrc, {PosAlign align = PosAlign.center}) {
    _socket.add(_generator.image(imgSrc, align: align));
  }

  Future<void> imageAsync(Image imgSrc, {PosAlign align = PosAlign.center}) async {
    await enqueueWithDelay(() {
      image(imgSrc, align: align);
    });
  }

  void imageWithText(Image imgSrc, String text, {PosAlign align = PosAlign.center}) {
    _socket.add(_generator.imageWithText(imgSrc, text, align: align));
  }

  Future<void> imageWithTextAsync(Image imgSrc, String text, {PosAlign align = PosAlign.center}) async {
    await enqueueWithDelay(() {
      imageWithText(imgSrc, text, align: align);
    });
  }

  void imageRaster(
    Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) {
    _socket.add(_generator.imageRaster(
      image,
      align: align,
      highDensityHorizontal: highDensityHorizontal,
      highDensityVertical: highDensityVertical,
      imageFn: imageFn,
    ));
  }

  Future<void> imageRasterAsync(
    Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) async {
    await enqueueWithDelay(() {
      imageRaster(
        image,
        align: align,
        highDensityHorizontal: highDensityHorizontal,
        highDensityVertical: highDensityVertical,
        imageFn: imageFn,
      );
    });
  }

  void barcode(
    Barcode barcode, {
    int? width,
    int? height,
    BarcodeFont? font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) {
    _socket.add(_generator.barcode(
      barcode,
      width: width,
      height: height,
      font: font,
      textPos: textPos,
      align: align,
    ));
  }

  Future<void> barcodeAsync(
    Barcode b, {
    int? width,
    int? height,
    BarcodeFont? font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) async {
    await enqueueWithDelay(() {
      barcode(
        b,
        width: width,
        height: height,
        font: font,
        textPos: textPos,
        align: align,
      );
    });
  }

  void qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) {
    _socket.add(_generator.qrcode(text, align: align, size: size, cor: cor));
  }

  Future<void> qrcodeAsync(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) async {
    await enqueueWithDelay(() {
      qrcode(text, align: align, size: size, cor: cor);
    });
  }

  void drawer({PosDrawer pin = PosDrawer.pin2}) {
    _socket.add(_generator.drawer(pin: pin));
  }

  Future<void> drawerAsync({PosDrawer pin = PosDrawer.pin2}) async {
    await enqueueWithDelay(() {
      drawer(pin: pin);
    });
  }

  void hr({String ch = '-', int? len, int linesAfter = 0}) {
    _socket.add(_generator.hr(ch: ch, linesAfter: linesAfter, len: len));
  }

  Future<void> hrAsync({String ch = '-', int? len, int linesAfter = 0}) async {
    await enqueueWithDelay(() {
      hr(ch: ch, linesAfter: linesAfter, len: len);
    });
  }

  void textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int? maxCharsPerLine,
  }) {
    _socket.add(_generator.textEncoded(
      textBytes,
      styles: styles,
      linesAfter: linesAfter,
      maxCharsPerLine: maxCharsPerLine,
    ));
  }

  Future<void> textEncodedAsync(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int? maxCharsPerLine,
  }) async {
    await enqueueWithDelay(() {
      textEncoded(
        textBytes,
        styles: styles,
        linesAfter: linesAfter,
        maxCharsPerLine: maxCharsPerLine,
      );
    });
  }

  Future<void> printBytes(List<int> bytes) async {
    await enqueueWithDelay(() {
      _socket.add(bytes);
    });
  }

  Future<void> printBytesAsync(List<int> bytes) async {
    await enqueueWithDelay(() {
      printBytes(bytes);
    });
  }

  void present() {
    _socket.add(_generator.present());
  }

  Future<void> presentAsync({PosDrawer pin = PosDrawer.pin2}) async {
    await enqueueWithDelay(() {
      present();
    });
  }
// ************************ (end) Printer Commands ************************
}
