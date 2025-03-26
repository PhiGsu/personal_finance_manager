import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

// Used to create, edit, or delete a transaction in the database
class TransactionForm extends StatefulWidget {
  final Map<int, String> categories;
  final Function(UserTransaction) onSave;
  final Function(UserTransaction)? onDelete;
  final UserTransaction? editTransaction;

  const TransactionForm({
    super.key,
    required this.categories,
    required this.onSave,
    this.onDelete,
    this.editTransaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late final TextEditingController costController;
  late final TextEditingController descriptionController;
  late DateTime date;
  int? selectedCategory;

  @override
  void initState() {
    super.initState();
    costController =
        TextEditingController(text: widget.editTransaction?.cost.toStringAsFixed(2));
    descriptionController =
        TextEditingController(text: widget.editTransaction?.description);
    date = widget.editTransaction?.date ?? DateTime.now();
    selectedCategory = widget.editTransaction?.categoryId;

    costController.addListener(_onTextChanged);
    descriptionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    costController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void resetForm() {
    costController.clear();
    descriptionController.clear();
    setState(() {
      date = DateTime.now();
      selectedCategory = null;
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool _areFieldsValid() {
    return double.tryParse(costController.text) != null &&
        descriptionController.text.isNotEmpty &&
        selectedCategory != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?[0-9]*(\.[0-9]{0,2})?$'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    maxLength: 100,
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            Wrap(alignment: WrapAlignment.start, runSpacing: 8, children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text(date.toIso8601String().split('T')[0]),
                        IconButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null && pickedDate != date) {
                              setState(() {
                                date = pickedDate;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ]),
                    )),
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                constraints: const BoxConstraints(maxWidth: 200),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: DropdownButton<int>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    borderRadius: BorderRadius.circular(5),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: widget.categories.entries
                        .map((entry) => DropdownMenuItem<int>(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  if (widget.editTransaction != null)
                    IconButton(
                      onPressed: () =>
                          widget.onDelete!(widget.editTransaction!),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                      ),
                      icon: const Icon(Icons.delete),
                    ),
                  IconButton(
                    onPressed: _areFieldsValid()
                        ? () {
                            final newTransaction = UserTransaction(
                              date: date,
                              cost: double.parse(costController.text),
                              description: descriptionController.text,
                              categoryId: selectedCategory!,
                              id: widget.editTransaction?.id,
                            );
                            widget.onSave(newTransaction);
                            resetForm();
                          }
                        : null,
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          _areFieldsValid()
                              ? Color(0xFFDAE8FC)
                              : const Color.fromARGB(255, 204, 204, 204),
                        ),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ))),
                    icon: widget.editTransaction == null
                        ? const Icon(Icons.add)
                        : const Icon(Icons.save),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
