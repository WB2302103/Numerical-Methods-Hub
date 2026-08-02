import '../models/complex_number.dart';

class IterationStep {
  final int iteration;
  final List<ComplexNumber> x;
  final double error;

  IterationStep({
    required this.iteration,
    required this.x,
    required this.error,
  });
}

class IterativeResult {
  final List<ComplexNumber> solution;
  final List<IterationStep> steps;
  final bool converged;

  IterativeResult({
    required this.solution,
    required this.steps,
    required this.converged,
  });
}

class IterativeMethods {
  static IterativeResult jacobi(
    List<List<ComplexNumber>> A,
    List<ComplexNumber> b, {
    double tolerance = 1e-6,
    int maxIterations = 100,
  }) {
    int n = A.length;
    List<ComplexNumber> x = List.filled(n, ComplexNumber.zero);
    List<IterationStep> steps = [];
    bool converged = false;

    for (int k = 1; k <= maxIterations; k++) {
      List<ComplexNumber> nextX = List.filled(n, ComplexNumber.zero);
      for (int i = 0; i < n; i++) {
        ComplexNumber sum = b[i];
        for (int j = 0; j < n; j++) {
          if (i != j) {
            sum = sum - (A[i][j] * x[j]);
          }
        }
        if (A[i][i].isZero) throw StateError("Zero diagonal element");
        nextX[i] = sum / A[i][i];
      }

      double error = _calculateError(x, nextX);
      x = nextX;
      steps.add(IterationStep(iteration: k, x: List.from(x), error: error));

      if (error < tolerance) {
        converged = true;
        break;
      }
    }

    return IterativeResult(solution: x, steps: steps, converged: converged);
  }

  static IterativeResult gaussSeidel(
    List<List<ComplexNumber>> A,
    List<ComplexNumber> b, {
    double tolerance = 1e-6,
    int maxIterations = 100,
  }) {
    int n = A.length;
    List<ComplexNumber> x = List.filled(n, ComplexNumber.zero);
    List<IterationStep> steps = [];
    bool converged = false;

    for (int k = 1; k <= maxIterations; k++) {
      List<ComplexNumber> oldX = List.from(x);
      for (int i = 0; i < n; i++) {
        ComplexNumber sum = b[i];
        for (int j = 0; j < n; j++) {
          if (i != j) {
            sum = sum - (A[i][j] * x[j]);
          }
        }
        if (A[i][i].isZero) throw StateError("Zero diagonal element");
        x[i] = sum / A[i][i];
      }

      double error = _calculateError(oldX, x);
      steps.add(IterationStep(iteration: k, x: List.from(x), error: error));

      if (error < tolerance) {
        converged = true;
        break;
      }
    }

    return IterativeResult(solution: x, steps: steps, converged: converged);
  }

  static double _calculateError(List<ComplexNumber> oldX, List<ComplexNumber> newX) {
    double sumSq = 0;
    for (int i = 0; i < oldX.length; i++) {
      double diff = (newX[i] - oldX[i]).magnitude;
      sumSq += diff * diff;
    }
    return sumSq > 0 ? sumSq : 0; // Simplified Euclidean distance squared
  }
}
