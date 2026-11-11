import 'package:flutter/material.dart';
import '../../core/models/calculator_module.dart';
import '../../core/theme/app_theme_extension.dart';
import 'calculation.dart';

class ToolkitModule extends CalculatorModule {
  final List<Calculation> modes;
  const ToolkitModule({required super.id, required super.name, required super.description,
    required super.category, required super.icon, required super.primaryColor, required this.modes});

  @override
  Widget buildUI(BuildContext context) => _ToolkitPage(module: this);
}

class _ToolkitPage extends StatefulWidget {
  final ToolkitModule module;
  const _ToolkitPage({required this.module});
  @override
  State<_ToolkitPage> createState() => _ToolkitPageState();
}

class _ToolkitPageState extends State<_ToolkitPage> {
  int selected = 0;
  late final drafts = [
    for (final mode in widget.module.modes) [for (final field in mode.fields) field.initial],
  ];

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final mode = module.modes[selected];
    final values = drafts[selected];
    final theme = context.omniTheme;
    Answers answers = {};
    String? error;
    try {
      answers = mode.evaluate(values);
    } on FormatException catch (e) {
      error = e.message;
    }
    return Scaffold(
      backgroundColor: theme.scaffoldBg,
      appBar: AppBar(title: Text(module.name), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        if (module.modes.length > 1) ...[
          DropdownButtonFormField<int>(
            value: selected, isExpanded: true,
            decoration: const InputDecoration(labelText: 'Calculation', border: OutlineInputBorder()),
            items: [for (var i = 0; i < module.modes.length; i++)
              DropdownMenuItem(value: i, child: Text(module.modes[i].title))],
            onChanged: (index) {
              if (index == null) return;
              FocusScope.of(context).unfocus();
              setState(() => selected = index);
            },
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardBg, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            for (var i = 0; i < mode.fields.length; i++)
              Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
                child: _field(mode.fields[i], i, values)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.cardBg, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Result', style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold)),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error)),
            for (final item in answers.entries)
              Padding(padding: const EdgeInsets.only(top: 12), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.key, style: TextStyle(color: theme.textSecondary)),
                  SelectableText(item.value, style: Theme.of(context).textTheme.titleLarge),
                ],
              )),
          ]),
        ),
      ])),
    );
  }

  Widget _field(Entry field, int index, List<String> values) {
    if (field.type == EntryType.date) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.calendar_today),
        label: Text('${field.label}   ${values[index]}'),
        onPressed: () async {
          final date = await showDatePicker(context: context, initialDate: DateTime.parse(values[index]),
            firstDate: DateTime(1600), lastDate: DateTime(9999, 12, 31));
          if (date != null && mounted) {
            setState(() => values[index] = date.toIso8601String().split('T').first);
          }
        },
      );
    }
    final multiline = field.type == EntryType.paragraph;
    return TextFormField(
      key: ValueKey('$selected/$index'), initialValue: values[index],
      keyboardType: field.type == EntryType.number
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : multiline ? TextInputType.multiline : TextInputType.text,
      minLines: multiline ? 3 : 1, maxLines: multiline ? 7 : 1,
      textInputAction: multiline ? TextInputAction.newline :
          index == values.length - 1 ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(labelText: field.label, border: const OutlineInputBorder()),
      onChanged: (v) => setState(() => values[index] = v),
    );
  }
}
