import 'package:pdf/widgets.dart' as pw;
import '../models/complex_number.dart';

class PdfExport {
  static Future<pw.Document> generateReport({
    required String methodName,
    required List<List<ComplexNumber>> A,
    required List<ComplexNumber> b,
    required List<ComplexNumber> solution,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text("Linear System Solver Report")),
              pw.SizedBox(height: 20),
              pw.Text("Method: $methodName"),
              pw.SizedBox(height: 20),
              pw.Text("Input Matrix A:"),
              pw.TableHelper.fromTextArray(
                data: A.map((row) => row.map((c) => c.toString()).toList()).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Vector b:"),
              pw.Text(b.map((c) => c.toString()).join(", ")),
              pw.SizedBox(height: 20),
              pw.Text("Final Solution x:", style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Column(
                children: List.generate(
                  solution.length,
                  (i) => pw.Text("x${i + 1} = ${solution[i]}"),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
