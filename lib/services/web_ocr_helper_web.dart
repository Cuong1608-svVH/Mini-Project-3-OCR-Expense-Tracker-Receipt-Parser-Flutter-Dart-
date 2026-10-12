import 'dart:async';
import 'dart:js_interop';

@JS('runWebOcr')
external JSPromise<JSString>? _runWebOcrJs(JSString base64Image);

Future<String> runWebOcr(String base64Data) async {
  try {
    final promise = _runWebOcrJs(base64Data.toJS);
    if (promise == null) return '';
    final result = await promise.toDart;
    return result.toDart;
  } catch (e) {
    return '';
  }
}
