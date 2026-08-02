import '../models/complex_number.dart';

class GaussianStep {
  final String description;
  final List<List<ComplexNumber>> matrix;
  final List<ComplexNumber> vector;

  GaussianStep({
    required this.description,
    required this.matrix,
    required this.vector,
  });
}

class GaussianResult {
  final List<ComplexNumber> solution;
  final List<GaussianStep> steps;

  GaussianResult({required this.solution, required this.steps});
}

class GaussianElimination {
  static GaussianResult solve(List<List<ComplexNumber>> A, List<ComplexNumber> b) {
    int n = A.length;
    List<List<ComplexNumber>> mat = A.map((row) => List<ComplexNumber>.from(row)).toList();
    List<ComplexNumber> vec = List<ComplexNumber>.from(b);
    List<GaussianStep> steps = [];

    steps.add(GaussianStep(
      description: "Initial Augmented Matrix",
      matrix: _cloneMatrix(mat),
      vector: List.from(vec),
    ));

    // Forward Elimination
    for (int i = 0; i < n; i++) {
      // Partial Pivoting
      int pivot = i;
      for (int j = i + 1; j < n; j++) {
        if (mat[j][i].magnitude > mat[pivot][i].magnitude) pivot = j;
      }

      if (pivot != i) {
        List<ComplexNumber> tempRow = mat[i];
        mat[i] = mat[pivot];
        mat[pivot] = tempRow;
        ComplexNumber tempVal = vec[i];
        vec[i] = vec[pivot];
        vec[pivot] = tempVal;

        steps.add(GaussianStep(
          description: "Swap Row ${i + 1} with Row ${pivot + 1}",
          matrix: _cloneMatrix(mat),
          vector: List.from(vec),
        ));
      }

      for (int j = i + 1; j < n; j++) {
        if (mat[i][i].isZero) continue;
        ComplexNumber factor = mat[j][i] / mat[i][i];
        for (int k = i; k < n; k++) {
          mat[j][k] = mat[j][k] - (factor * mat[i][k]);
        }
        vec[j] = vec[j] - (factor * vec[i]);
      }
      
      steps.add(GaussianStep(
        description: "Eliminate column ${i + 1}",
        matrix: _cloneMatrix(mat),
        vector: List.from(vec),
      ));
    }

    // Back Substitution
    List<ComplexNumber> x = List.filled(n, ComplexNumber.zero);
    for (int i = n - 1; i >= 0; i--) {
      ComplexNumber sum = vec[i];
      for (int j = i + 1; j < n; j++) {
        sum = sum - (mat[i][j] * x[j]);
      }
      if (mat[i][i].isZero) throw StateError("Singular matrix");
      x[i] = sum / mat[i][i];
    }

    return GaussianResult(solution: x, steps: steps);
  }

  static List<List<ComplexNumber>> _cloneMatrix(List<List<ComplexNumber>> m) {
    return m.map((row) => List<ComplexNumber>.from(row)).toList();
  }
}
