import 'dart:typed_data';

/// Wraps a key as a fixed Uint8List and zeros it on dispose.
/// Never use String for key material — strings are interned and GC'd non-deterministically.
class SecureKey {
  SecureKey(this._bytes);

  Uint8List _bytes;
  bool _disposed = false;

  Uint8List get bytes {
    if (_disposed) throw StateError('SecureKey has been disposed');
    return _bytes;
  }

  int get length => _bytes.length;

  bool get isDisposed => _disposed;

  /// Zero the key bytes and mark as disposed.
  void dispose() {
    if (_disposed) return;
    _bytes.fillRange(0, _bytes.length, 0);
    _disposed = true;
  }

  /// Create a copy — caller is responsible for disposing.
  SecureKey copy() {
    if (_disposed) throw StateError('Cannot copy disposed SecureKey');
    return SecureKey(Uint8List.fromList(_bytes));
  }
}
