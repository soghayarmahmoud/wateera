import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wateera/models/note_model.dart';
import 'package:wateera/providers/note_provider.dart';
import 'dart:math';

class NoteBottomSheet extends StatefulWidget {
  final Note? note;

  const NoteBottomSheet({super.key, this.note});

  @override
  State<NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<NoteBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = Color(widget.note!.color);
    } else {
      _selectedColor =
          Colors.primaries[Random().nextInt(Colors.primaries.length)];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Content'),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          // Simple color picker
          Row(
            children: [
              const Text('Color:'),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = Colors
                        .primaries[Random().nextInt(Colors.primaries.length)];
                  });
                },
                child: CircleAvatar(
                  backgroundColor: _selectedColor,
                  radius: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final noteProvider = Provider.of<NoteProvider>(
                context,
                listen: false,
              );
              final newNote = Note(
                id: widget.note?.id ?? const Uuid().v4(),
                title: _titleController.text,
                content: _contentController.text,
                createdAt: widget.note?.createdAt ?? DateTime.now(),
                color: _selectedColor.value,
              );
              if (widget.note == null) {
                noteProvider.addNote(newNote);
              } else {
                noteProvider.updateNote(newNote);
              }
              Navigator.pop(context);
            },
            child: Text(widget.note == null ? 'Add Note' : 'Update Note'),
          ),
        ],
      ),
    );
  }
}
