import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../providers/note_provider.dart';

class NoteBottomSheet extends StatefulWidget {
  final Note? note;

  const NoteBottomSheet({super.key, this.note});

  @override
  State<NoteBottomSheet> createState() => _NoteBottomSheetState();
}

class _NoteBottomSheetState extends State<NoteBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late int _selectedColor;

  final List<int> _colors = [
    0xFFFFFFFF,
    0xFFF28B82,
    0xFFFBBC04,
    0xFFFFF475,
    0xFFCCFF90,
    0xFFA7FFEB,
    0xFFCBF0F8,
    0xFFAFCBFA,
    0xFFD7AEFB,
    0xFFFDCFE8,
    0xFFE6C9A8,
    0xFFE8EAED,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedColor = widget.note!.color;
    } else {
      _selectedColor = _colors.first;
    }
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
          Text(widget.note == null ? 'Add Note' : 'Edit Note', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final color = _colors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveNote,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    if (widget.note == null) {
      final newNote = Note(
        id: const Uuid().v4(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        color: _selectedColor,
      );
      noteProvider.addNote(newNote);
    } else {
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        color: _selectedColor,
      );
      noteProvider.updateNote(updatedNote);
    }

    Navigator.pop(context);
  }
}