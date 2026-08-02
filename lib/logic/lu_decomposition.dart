import '../models/complex_number.dart';

class LUResult {
  final List<List<ComplexNumber>> L;
  final List<List<ComplexNumber>> U;
  final List<int> pivotOrder; // maps new row index -> original row index
  final bool singular;

  LUResult({
    required this.L,
    required this.U,
    required this.pivotOrder,
    required this.singular,
  });
}

class LUDecomposition {
  /// Doolittle's method with partial pivoting for complex-valued matrices.
  static LUResult decompose(List<List<ComplexNumber>> A) {
    final n = A.length;

    List<List<ComplexNumber>> U =
        A.map((row) => List<ComplexNumber>.from(row)).toList();
    List<List<ComplexNumber>> L = List.generate(
      n,
      (i) => List.generate(
        n,
        (j) => i == j ? const ComplexNumber(1, 0) : ComplexNumber.zero,
      ),
    );
    List<int> pivotOrder = List.generate(n, (i) => i);

    bool singular = false;

    for (int k = 0; k < n; k++) {
      int maxRow = k;
      double maxMag = U[k][k].magnitude;
      for (int i = k + 1; i < n; i++) {
        if (U[i][k].magnitude > maxMag) {
          maxMag = U[i][k].magnitude;
          maxRow = i;
        }
      }

      if (maxMag < 1e-12) {
        singular = true;
        continue;
      }

      if (maxRow != k) {
        final tempU = U[k];
        U[k] = U[maxRow];
        U[maxRow] = tempU;

        for (int j = 0; j < k; j++) {
          final tempL = L[k][j];
          L[k][j] = L[maxRow][j];
          L[maxRow][j] = tempL;
        }

        final tempP = pivotOrder[k];
        pivotOrder[k] = pivotOrder[maxRow];
        pivotOrder[maxRow] = tempP;
      }

      for (int i = k + 1; i < n; i++) {
        final factor = U[i][k] / U[k][k];
        L[i][k] = factor;
        for (int j = k; j < n; j++) {
          U[i][j] = U[i][j] - (factor * U[k][j]);
        }
      }
    }

    return LUResult(L: L, U: U, pivotOrder: pivotOrder, singular: singular);
  }

  /// Solves Ax = b using the LU result: Ly = Pb, then Ux = y.
  static List<ComplexNumber> solve(LUResult lu, List<ComplexNumber> b) {
    final n = lu.L.length;
    final pb = List<ComplexNumber>.generate(n, (i) => b[lu.pivotOrder[i]]);

    final y = List<ComplexNumber>.filled(n, ComplexNumber.zero);
    for (int i = 0; i < n; i++) {
      ComplexNumber sum = pb[i];
      for (int j = 0; j < i; j++) {
        sum = sum - (lu.L[i][j] * y[j]);
      }
      y[i] = sum;
    }

    final x = List<ComplexNumber>.filled(n, ComplexNumber.zero);
    for (int i = n - 1; i >= 0; i--) {
      ComplexNumber sum = y[i];
      for (int j = i + 1; j < n; j++) {
        sum = sum - (lu.U[i][j] * x[j]);
      }
      if (lu.U[i][i].isZero) {
        throw StateError('Matrix is singular: no unique solution exists.');
      }
      x[i] = sum / lu.U[i][i];
    }

    return x;
  }
}
