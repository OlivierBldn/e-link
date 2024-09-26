import 'dart:convert';
import 'package:es_compression/framework.dart';

// This class is used to compress the data to be sent via BLE
class CompressionProvider extends Codec<List<int>, List<int>> {
  CompressionProvider();

  // split [bytes] into a sublist of [mtu] size
  List<List<T>> splitIntoChuncks<T>(List<T> bytes, int mtu) {
    List<List<T>> resultat = [];
    for (int i = 0; i < bytes.length; i += mtu) {
      int fin = (i + mtu < bytes.length) ? i + mtu : bytes.length;
      resultat.add(bytes.sublist(i, fin));
    }
    return resultat;
  }

  @override
  Converter<List<int>, List<int>> get decoder => RunLengthDecoder();

  @override
  Converter<List<int>, List<int>> get encoder => RunLengthEncoder();
}

/// Custom encoder that provides a [CodecSink] with the algorithm
/// [RunLengthEncoderFilter].
class RunLengthEncoder extends CodecConverter {
  @override
  ByteConversionSink startChunkedConversion(Sink<List<int>> sink) {
    final byteSink = asByteSink(sink);
    return CodecSink(byteSink, RunLengthEncoderFilter());
  }
}

/// Filter that encodes the incoming bytes using a Dart in-memory buffer.
class RunLengthEncoderFilter extends DartCodecFilterBase {
  int runLength = 1;

  @override
  CodecResult doProcessing(
      DartCodecBuffer inputBuffer, DartCodecBuffer outputBuffer) {
    final readPos = inputBuffer.readCount;
    final writePos = outputBuffer.writeCount;
    while (!inputBuffer.atEnd() && outputBuffer.unwrittenCount > 1) {
      const maxRunLength = 9;
      final next = inputBuffer.next();
      if (runLength < maxRunLength && inputBuffer.peek() == next) {
        runLength++;
      } else {
        final runLengthBytes = utf8.encode(runLength.toString());
        outputBuffer
          ..nextPutAll(runLengthBytes)
          ..nextPut(next);
        runLength = 1;
      }
    }
    final read = inputBuffer.readCount - readPos;
    final written = outputBuffer.writeCount - writePos;
    return CodecResult(read, written, adjustBufferCounts: false);
  }
}

/// Custom decoder that provides a [CodecSink] with the algorithm
/// [RunLengthDecoderFilter].
class RunLengthDecoder extends CodecConverter {
  @override
  ByteConversionSink startChunkedConversion(Sink<List<int>> sink) {
    final byteSink = asByteSink(sink);
    return CodecSink(byteSink, RunLengthDecoderFilter());
  }
}

enum RleState { expectingLength, expectingData }

/// Filter that decodes the incoming bytes using a Dart in-memory buffer.
class RunLengthDecoderFilter extends DartCodecFilterBase {
  RleState _state = RleState.expectingLength;
  int runLength = 1;

  @override
  CodecResult doProcessing(
      DartCodecBuffer inputBuffer, DartCodecBuffer outputBuffer) {
    final readPos = inputBuffer.readCount;
    final writePos = outputBuffer.writeCount;
    while (!inputBuffer.atEnd() && !outputBuffer.isFull()) {
      switch (_state) {
        case RleState.expectingLength:
          final runLengthStr = String.fromCharCode(inputBuffer.next());
          runLength = int.parse(runLengthStr);
          _state = RleState.expectingData;
          break;
        case RleState.expectingData:
          final nextChar = inputBuffer.next();
          for (var i = 0; i < runLength; i++) {
            outputBuffer.nextPut(nextChar);
          }
          _state = RleState.expectingLength;
          break;
      }
    }
    final read = inputBuffer.readCount - readPos;
    final written = outputBuffer.writeCount - writePos;
    return CodecResult(read, written, adjustBufferCounts: false);
  }
}
