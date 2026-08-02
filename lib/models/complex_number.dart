import 'dart:math';

/// A custom complex number type since Dart has no built-in complex support.
class ComplexNumber {
  final double real;
  final double imag;

  const ComplexNumber(this.real, this.imag);

  static const zero = ComplexNumber(0, 0);

  ComplexNumber operator +(ComplexNumber other) =>
      ComplexNumber(real + other.real, imag + other.imag);

  ComplexNumber operator -(ComplexNumber other) =>
      ComplexNumber(real - other.real, imag - other.imag);

  ComplexNumber operator *(ComplexNumber other) => ComplexNumber(
        real * other.real - imag * other.imag,
        real * other.imag + imag * other.real,
      );

  ComplexNumber operator /(ComplexNumber other) {
    final denom = other.real * other.real + other.imag * other.imag;
    if (denom == 0) {
      throw ArgumentError('Division by zero complex number');
    }
    return ComplexNumber(
      (real * other.real + imag * other.imag) / denom,
      (imag * other.real - real * other.imag) / denom,
    );
  }

  double get magnitude => sqrt(real * real + imag * imag);

  bool get isZero => real == 0 && imag == 0;

  /// Parses strings like "3+2i", "3-2i", "-4i", "5", "2i", "-2-3i"
  factory ComplexNumber.parse(String input) {
    String s = input.trim().replaceAll(' ', '');
    if (s.isEmpty) {
      throw FormatException('Empty input');
    }
    if (!s.contains('i')) {
      return ComplexNumber(double.parse(s), 0);
    }

    s = s.substring(0, s.length - 1); // drop trailing 'i'
    if (s.isEmpty || s == '+') return const ComplexNumber(0, 1);
    if (s == '-') return const ComplexNumber(0, -1);

    int splitIndex = -1;
    for (int i = 1; i < s.length; i++) {
      if (s[i] == '+' || s[i] == '-') {
        splitIndex = i;
      }
    }

    if (splitIndex == -1) {
      return ComplexNumber(0, double.parse(s));
    }

    final realPart = s.substring(0, splitIndex);
    String imagPart = s.substring(splitIndex);
    if (imagPart == '+') imagPart = '1';
    if (imagPart == '-') imagPart = '-1';
    return ComplexNumber(double.parse(realPart), double.parse(imagPart));
  }

  @override
  String toString() {
    if (imag == 0) return _fmt(real);
    if (real == 0) return '${_fmt(imag)}i';
    final sign = imag < 0 ? '-' : '+';
    return '${_fmt(real)}$sign${_fmt(imag.abs())}i';
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(4);
  }
}
