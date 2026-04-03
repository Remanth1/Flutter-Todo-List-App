import 'package:flutter/material.dart';

class AddTaskField extends StatefulWidget {
  const AddTaskField({
    super.key,
    required this.hint,
    required this.onSubmit,
    this.onOpenAdvanced,
  });

  final String hint;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String>? onOpenAdvanced;

  @override
  State<AddTaskField> createState() => _AddTaskFieldState();
}

class _AddTaskFieldState extends State<AddTaskField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSubmit(text);
    _controller.clear();
  }

  void _openAdvanced() {
    final title = _controller.text.trim();
    widget.onOpenAdvanced?.call(title);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.add, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Add task',
          ),
          if (widget.onOpenAdvanced != null)
            IconButton(
              onPressed: _openAdvanced,
              icon: const Icon(Icons.tune),
              tooltip: 'More options',
            ),
        ],
      ),
    );
  }
}

