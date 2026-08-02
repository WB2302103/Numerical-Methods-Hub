import '../models/complex_number.dart';

class InversionStep {
  final String description;
  final List<List<ComplexNumber>> matrix;

  InversionStep({required this.description, required this.matrix});
}

class InversionResult {
  final List<List<ComplexNumber>> inverse;
  final List<InversionStep> steps;

  InversionResult({required this.inverse, required this.steps});
}

class MatrixInversion {
  static InversionResult invert(List<List<ComplexNumber>> A) {
    int n = A.length;
    List<List<ComplexNumber>> augmented = List.generate(n, (i) {
      List<ComplexNumber> row = List<ComplexNumber>.from(A[i]);
      row.addAll(List.generate(n, (j) => i == j ? const ComplexNumber(1, 0) : ComplexNumber.zero));
      return row;
    });

    List<InversionStep> steps = [];
    steps.add(InversionStep(description: "Augmented Matrix [A|I]", matrix: _cloneMatrix(augmented)));

    for (int i = 0; i < n; i++) {
      // Partial pivoting
      int pivot = i;
      for (int j = i + 1; j < n; j++) {
        if (augmented[j][i].magnitude > augmented[pivot][i].magnitude) pivot = j;
      }

      if (pivot != i) {
        List<ComplexNumber> temp = augmented[i];
        augmented[i] = augmented[pivot];
        augmented[pivot] = temp;
        steps.add(InversionStep(description: "Swap R${i + 1} with R${pivot + 1}", matrix: _cloneMatrix(augmented)));
      }

      ComplexNumber pivotVal = augmented[i][i];
      if (pivotVal.isZero) throw StateError("Matrix is singular");

      // Normalize pivot row
      for (int j = 0; j < 2 * n; j++) {
        augmented[i][j] = augmented[i][j] / pivotVal;
      }
      steps.add(InversionStep(description: "Normalize R${i + 1}", matrix: _cloneMatrix(augmented)));

      // Eliminate other rows
      for (int k = 0; k < n; k++) {
        if (k != i) {
          ComplexNumber factor = augmented[k][i];
          for (int j = 0; j < 2 * n; j++) {
            augmented[k][j] = augmented[k][j] - (factor * augmented[i][j]);
          }
        }
      }
      steps.add(InversionStep(description: "Eliminate column ${i + 1}", matrix: _cloneMatrix(augmented)));
    }

    List<List<ComplexNumber>> inverse = augmented.map((row) => row.sublist(n)).toList();
    return InversionResult(inverse: inverse, steps: steps);
  }

  static List<List<ComplexNumber>> _cloneMatrix(List<List<ComplexNumber>> m) {
    return m.map((row) => List<ComplexNumber>.from(row)).toList();
  }
}
