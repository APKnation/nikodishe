import 'dart:typed_data';
import 'dart:ui' as ui;

/// Hupunguza ukubwa wa picha ya wasifu na kuibadilisha kuwa PNG.
///
/// Inafanya kazi kwenye Android, iOS na Web (haitumii `dart:io`),
/// hivyo picha zinazotoka kwenye kamera/gallery zinakuwa nyepesi
/// kabla ya kutumwa kwenye backend.
Future<Uint8List> prepareProfileImage(
  Uint8List bytes, {
  int maxDimension = 512,
}) async {
  if (bytes.isEmpty) return bytes;

  try {
    // Soma vipimo halisi vya picha kwanza.
    final probe = await ui.instantiateImageCodec(bytes);
    final frame = await probe.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;
    image.dispose();
    probe.dispose();

    final alreadySmall =
        width <= maxDimension &&
        height <= maxDimension &&
        bytes.length <= 900 * 1024;
    if (alreadySmall) return bytes;

    var targetWidth = width;
    var targetHeight = height;
    if (width >= height && width > maxDimension) {
      targetWidth = maxDimension;
      targetHeight = (height * maxDimension / width).round().clamp(
        1,
        maxDimension,
      ).toInt();
    } else if (height > maxDimension) {
      targetHeight = maxDimension;
      targetWidth = (width * maxDimension / height).round().clamp(
        1,
        maxDimension,
      ).toInt();
    }

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
    final resized = await codec.getNextFrame();
    final data = await resized.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    resized.image.dispose();
    codec.dispose();

    if (data != null) {
      return data.buffer.asUint8List();
    }
  } catch (_) {
    // Rudi kwenye bytes za awali kama resize imeshindikana.
  }

  return bytes;
}
