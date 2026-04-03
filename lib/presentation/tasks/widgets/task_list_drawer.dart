import 'package:flutter/material.dart';

import '../../../domain/entities/task_list.dart';

class TaskListDrawer extends StatelessWidget {
  const TaskListDrawer({
    super.key,
    required this.lists,
    required this.selectedListId,
    required this.onSelectList,
    required this.onCreateList,
  });

  final List<TaskList> lists;
  final String? selectedListId;
  final ValueChanged<String> onSelectList;
  final ValueChanged<String> onCreateList;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              title: Text(
                'Lists',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  return ListTile(
                    selected: list.id == selectedListId,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    leading: const Icon(Icons.list_alt_outlined),
                    title: Text(list.title),
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectList(list.id);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create list'),
              onTap: () async {
                final controller = TextEditingController();
                final title = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('New list'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(hintText: 'List title'),
                        onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
                          child: const Text('Create'),
                        ),
                      ],
                    );
                  },
                );

                if (title != null && title.trim().isNotEmpty) {
                  onCreateList(title.trim());
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

