import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/wateera_app_bar.dart';
import '../providers/note_provider.dart';
import '../components/note_bottom_sheet.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      appBar: const WateeraAppBar(title: Text('Notes')),
      body: noteProvider.notes.isEmpty
          ? const Center(
              child: Text('No notes yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: noteProvider.notes.length,
              itemBuilder: (context, index) {
                final note = noteProvider.notes[index];
                return Card(
                  color: Color(note.color),
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(note.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => NoteBottomSheet(note: note),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        noteProvider.deleteNote(note.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const NoteBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}