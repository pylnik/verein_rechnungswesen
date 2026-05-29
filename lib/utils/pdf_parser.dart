import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Stub PDF parser — extracts plain text from a PDF file.
///
/// In a later sprint this will be used to auto-fill transaction fields
/// from bank statements or invoices exported as PDF.
class PdfParser {
  /// Returns the concatenated text content of all pages in [pdfBytes].
  static String extractText(List<int> pdfBytes) {
    final document = PdfDocument(inputBytes: pdfBytes);
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();
    return text;
  }
}
