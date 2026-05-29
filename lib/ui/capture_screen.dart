import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../data/app_state.dart';
import '../models/transaction.dart';

class CaptureScreen extends StatefulWidget {
  final AppState appState;
  const CaptureScreen({super.key, required this.appState});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _personCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  PaymentMethod _paymentMethod = PaymentMethod.konto;
  String? _selectedCategory;
  String? _pdfPath;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _personCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pdfPath = result.files.single.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final rawAmount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
    final amount = _type == TransactionType.expense ? -rawAmount.abs() : rawAmount.abs();

    final transaction = Transaction(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      amount: amount,
      category: _selectedCategory ?? widget.appState.categories.first.name,
      paymentMethod: _paymentMethod,
      notes: _notesCtrl.text.trim(),
      pdfFile: _pdfPath,
      type: _type,
      person: _type == TransactionType.reimbursement ? _personCtrl.text.trim() : null,
    );

    await widget.appState.addTransaction(transaction);
    if (mounted) {
      _amountCtrl.clear();
      _notesCtrl.clear();
      _personCtrl.clear();
      setState(() => _pdfPath = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Buchung gespeichert.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.appState.categories;
    _selectedCategory ??= categories.isNotEmpty ? categories.first.name : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Buchung erfassen'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Ausgabe')),
                  ButtonSegment(value: TransactionType.income, label: Text('Einnahme')),
                  ButtonSegment(value: TransactionType.reimbursement, label: Text('Erstattung')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Betrag (€)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bitte Betrag eingeben';
                  final n = double.tryParse(v.replaceAll(',', '.'));
                  if (n == null || n <= 0) return 'Ungültiger Betrag';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategorie',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c.name, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Bitte Kategorie wählen' : null,
              ),
              const SizedBox(height: 16),
              // Payment method
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Zahlungsart',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: PaymentMethod.konto, child: Text('Konto')),
                  DropdownMenuItem(value: PaymentMethod.bar, child: Text('Bar')),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              const SizedBox(height: 16),
              // Person (only for reimbursements)
              if (_type == TransactionType.reimbursement) ...[
                TextFormField(
                  controller: _personCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Person',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    if (_type == TransactionType.reimbursement &&
                        (v == null || v.isEmpty)) {
                      return 'Bitte Person eingeben';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Notes
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notizen',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              // PDF attachment
              OutlinedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.attach_file),
                label: Text(_pdfPath == null ? 'PDF anhängen' : 'PDF: ${_pdfPath!.split('/').last}'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Speichern'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
