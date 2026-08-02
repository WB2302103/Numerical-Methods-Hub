import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/complex_number.dart';
import '../logic/lu_decomposition.dart';
import '../logic/gaussian_elimination.dart';
import '../logic/iterative_methods.dart';
import '../logic/matrix_inversion.dart';
import '../logic/pdf_export.dart';
import '../logic/database_service.dart';
import '../logic/auth_service.dart';
import 'tutorial_screen.dart';

enum SolverMethod { lu, gaussian, inversion, jacobi, gaussSeidel }

class SolverScreen extends StatefulWidget {
  final SolverMethod method;
  const SolverScreen({super.key, required this.method});

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> {
  int n = 3;
  List<List<TextEditingController>> matrixControllers = [];
  List<TextEditingController> vectorControllers = [];
  final TextEditingController toleranceController = TextEditingController(text: '1e-6');
  final TextEditingController maxIterController = TextEditingController(text: '100');

  String? errorMessage;
  dynamic result; 
  List<ComplexNumber>? solution;
  int currentStep = 0;
  bool _isSavingFavorite = false;

  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  void _buildControllers() {
    matrixControllers = List.generate(
      n,
      (i) => List.generate(
        n,
        (j) => TextEditingController(text: ''),
      ),
    );
    vectorControllers = List.generate(n, (i) => TextEditingController(text: ''));
  }

  void _loadSample() {
    setState(() {
      n = 3;
      _buildControllers();
      matrixControllers[0][0].text = "4"; matrixControllers[0][1].text = "1"; matrixControllers[0][2].text = "2";
      matrixControllers[1][0].text = "1"; matrixControllers[1][1].text = "5"; matrixControllers[1][2].text = "1";
      matrixControllers[2][0].text = "2"; matrixControllers[2][1].text = "1"; matrixControllers[2][2].text = "6";

      vectorControllers[0].text = "7";
      vectorControllers[1].text = "7";
      vectorControllers[2].text = "9";
      errorMessage = null;
      solution = null;
      result = null;
    });
  }

  bool _validateInput() {
    for (var row in matrixControllers) {
      for (var controller in row) {
        if (controller.text.trim().isEmpty) return false;
        try { ComplexNumber.parse(controller.text); } catch (e) { return false; }
      }
    }
    for (var controller in vectorControllers) {
      if (controller.text.trim().isEmpty) return false;
      try { ComplexNumber.parse(controller.text); } catch (e) { return false; }
    }
    return true;
  }

  void _solve() {
    if (!_validateInput()) {
      setState(() => errorMessage = "Please enter valid numeric values in all fields.");
      return;
    }

    setState(() {
      errorMessage = null;
      result = null;
      solution = null;
      currentStep = 0;
    });

    try {
      final A = matrixControllers.map((row) => row.map((c) => ComplexNumber.parse(c.text)).toList()).toList();
      final b = vectorControllers.map((c) => ComplexNumber.parse(c.text)).toList();

      switch (widget.method) {
        case SolverMethod.lu:
          final lu = LUDecomposition.decompose(A);
          if (lu.singular) throw 'Matrix is singular';
          solution = LUDecomposition.solve(lu, b);
          result = lu;
          break;
        case SolverMethod.gaussian:
          final res = GaussianElimination.solve(A, b);
          solution = res.solution;
          result = res;
          break;
        case SolverMethod.inversion:
          final res = MatrixInversion.invert(A);
          result = res;
          solution = List.generate(n, (i) {
            ComplexNumber sum = ComplexNumber.zero;
            for (int j = 0; j < n; j++) {
              sum = sum + (res.inverse[i][j] * b[j]);
            }
            return sum;
          });
          break;
        case SolverMethod.jacobi:
          final res = IterativeMethods.jacobi(A, b, 
            tolerance: double.tryParse(toleranceController.text) ?? 1e-6,
            maxIterations: int.tryParse(maxIterController.text) ?? 100);
          solution = res.solution;
          result = res;
          break;
        case SolverMethod.gaussSeidel:
          final res = IterativeMethods.gaussSeidel(A, b,
            tolerance: double.tryParse(toleranceController.text) ?? 1e-6,
            maxIterations: int.tryParse(maxIterController.text) ?? 100);
          solution = res.solution;
          result = res;
          break;
      }
      _saveToHistory();
    } catch (e) {
      setState(() => errorMessage = 'Calculation Error: $e');
    }
  }

  void _saveToHistory() async {
    if (solution == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.currentUserId == null) return;

    final A = matrixControllers.map((row) => row.map((c) => c.text).toList()).toList();
    final b = vectorControllers.map((c) => c.text).toList();
    final sol = solution!.map((c) => c.toString()).toList();
    String methodStr = widget.method.toString().split('.').last;

    await DatabaseService().saveSolvedProblem(
      uid: auth.currentUserId!,
      method: methodStr,
      matrix: A,
      constantVector: b,
      answer: sol,
    );
  }

  void _saveToFavorites() async {
    if (solution == null) return;
    final auth = Provider.of<AuthService>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    
    setState(() => _isSavingFavorite = true);
    try {
      final A = matrixControllers.map((row) => row.map((c) => c.text).toList()).toList();
      final b = vectorControllers.map((c) => c.text).toList();
      final sol = solution!.map((c) => c.toString()).toList();
      
      await DatabaseService().saveFavorite(auth.currentUserId!, {
        'method': widget.method.toString().split('.').last,
        'matrix': A,
        'constantVector': b,
        'answer': sol,
      });
      messenger.showSnackBar(const SnackBar(content: Text("Added to Favorites!")));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSavingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Solver";
    switch(widget.method) {
      case SolverMethod.lu: title = "LU Decomposition"; break;
      case SolverMethod.gaussian: title = "Gaussian Elimination"; break;
      case SolverMethod.inversion: title = "Matrix Inversion"; break;
      case SolverMethod.jacobi: title = "Jacobi Iterative Method"; break;
      case SolverMethod.gaussSeidel: title = "Gauss-Seidel Method"; break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TutorialScreen(topic: title))),
            tooltip: "Theory & Tutorial",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Size: '),
                DropdownButton<int>(
                  value: n,
                  items: [2, 3, 4, 5].map((s) => DropdownMenuItem(value: s, child: Text('$s x $s'))).toList(),
                  onChanged: (v) { if (v != null) setState(() { n = v; _buildControllers(); }); },
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadSample,
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Load Sample', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            if (widget.method == SolverMethod.jacobi || widget.method == SolverMethod.gaussSeidel)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: toleranceController, decoration: const InputDecoration(labelText: 'Tolerance', isDense: true, border: OutlineInputBorder()))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: maxIterController, decoration: const InputDecoration(labelText: 'Max Iter', isDense: true, border: OutlineInputBorder()))),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            _buildMatrixGrid(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _solve, 
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('Solve Now')
              ),
            ),
            if (errorMessage != null) 
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            const Divider(height: 30),
            _buildStepVisualization(),
            if (solution != null) ...[
              _buildValidationView(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Final Solution x:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Row(
                    children: [
                      IconButton(
                        icon: _isSavingFavorite ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.favorite_border),
                        onPressed: _isSavingFavorite ? null : _saveToFavorites,
                        tooltip: "Save to Favorites",
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () async {
                          final A = matrixControllers.map((row) => row.map((c) => ComplexNumber.parse(c.text)).toList()).toList();
                          final b = vectorControllers.map((c) => ComplexNumber.parse(c.text)).toList();
                          final messenger = ScaffoldMessenger.of(context);
                          await PdfExport.generateReport(methodName: title, A: A, b: b, solution: solution!);
                          messenger.showSnackBar(const SnackBar(content: Text("PDF Report generated successfully!")));
                        },
                        tooltip: "Export to PDF",
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(solution!.length, (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text("x${i+1} = ${solution![i]}", style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
                  )),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixGrid() {
    return Column(
      children: List.generate(n, (i) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(n, (j) => Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                width: 65, 
                child: TextField(
                  controller: matrixControllers[i][j], 
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10))
                )
              ),
            )),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text("|", style: TextStyle(fontSize: 20, color: Colors.grey))),
            Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                width: 65, 
                child: TextField(
                  controller: vectorControllers[i], 
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(border: const OutlineInputBorder(), isDense: true, labelText: 'b${i+1}', contentPadding: const EdgeInsets.all(10))
                )
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildValidationView() {
    if (solution == null) return const SizedBox.shrink();
    final A = matrixControllers.map((row) => row.map((c) => ComplexNumber.parse(c.text)).toList()).toList();
    final b = vectorControllers.map((c) => ComplexNumber.parse(c.text)).toList();

    List<ComplexNumber> ax = List.generate(n, (i) {
      ComplexNumber sum = ComplexNumber.zero;
      for (int j = 0; j < n; j++) { sum = sum + (A[i][j] * solution![j]); }
      return sum;
    });

    double totalError = 0;
    for (int i = 0; i < n; i++) { totalError += (ax[i] - b[i]).magnitude; }

    return Card(
      color: totalError < 1e-6 ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Solution Validation (Ax = b check):", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            ...List.generate(n, (i) => Text("Row ${i + 1}: Ax = ${ax[i].toString()} vs b = ${b[i].toString()}", style: const TextStyle(fontSize: 12))),
            const Divider(),
            Text("Total Absolute Error: ${totalError == 0 ? '0' : totalError.toStringAsExponential(4)}", 
                 style: TextStyle(fontWeight: FontWeight.bold, color: totalError < 1e-6 ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepVisualization() {
    if (result == null) return const SizedBox.shrink();
    if (result is GaussianResult) {
      final res = result as GaussianResult;
      return _buildGenericStepView(res.steps.length, (idx) {
        final step = res.steps[idx];
        return Column(children: [Text(step.description, style: const TextStyle(fontWeight: FontWeight.bold)), _buildMatrixWithVector(step.matrix, step.vector)]);
      });
    }
    if (result is InversionResult) {
      final res = result as InversionResult;
      return _buildGenericStepView(res.steps.length, (idx) {
        final step = res.steps[idx];
        return Column(children: [Text(step.description, style: const TextStyle(fontWeight: FontWeight.bold)), _buildMatrixDisplay("", step.matrix)]);
      });
    }
    if (result is IterativeResult) {
      final res = result as IterativeResult;
      return Column(
        children: [
          const Text("Convergence History", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 200, child: LineChart(_buildChartData(res.steps))),
          Text("Total Iterations: ${res.steps.length}"),
          if (!res.converged) const Text("Did not converge!", style: TextStyle(color: Colors.red)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildGenericStepView(int count, Widget Function(int) builder) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(onPressed: currentStep > 0 ? () => setState(() => currentStep--) : null, icon: const Icon(Icons.arrow_back)),
          Text("Step ${currentStep + 1} of $count"),
          IconButton(onPressed: currentStep < count - 1 ? () => setState(() => currentStep++) : null, icon: const Icon(Icons.arrow_forward)),
        ]),
        builder(currentStep),
      ],
    );
  }

  LineChartData _buildChartData(List<IterationStep> steps) {
    return LineChartData(
      lineBarsData: [LineChartBarData(spots: steps.map((s) => FlSpot(s.iteration.toDouble(), s.error)).toList(), isCurved: true, color: Colors.indigo, dotData: const FlDotData(show: false))],
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(axisNameWidget: Text("Error"), sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        bottomTitles: AxisTitles(axisNameWidget: Text("Iteration"), sideTitles: SideTitles(showTitles: true)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );
  }

  Widget _buildMatrixWithVector(List<List<ComplexNumber>> matrix, List<ComplexNumber> vector) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: List.generate(matrix.length, (i) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("[ ${matrix[i].map((c) => c.toString()).join('  ')} ]"), const SizedBox(width: 10), Text("| ${vector[i]} |")]);
    })));
  }

  Widget _buildMatrixDisplay(String label, List<List<ComplexNumber>> matrix) {
    return Column(children: [if (label.isNotEmpty) Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), ...matrix.map((row) => Text("[ ${row.map((c) => c.toString()).join('  ')} ]"))]);
  }
}
