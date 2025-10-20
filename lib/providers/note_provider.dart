import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  late Box<Note> _noteBox;

  NoteProvider() {
    _noteBox = Hive.box<Note>('notes');
  }

  List<Note> get notes => _noteBox.values.toList();

  List<Note> getNotesForDate(DateTime date) {
    return _noteBox.values.where((note) {
      return note.createdAt.year == date.year &&
          note.createdAt.month == date.month &&
          note.createdAt.day == date.day;
    }).toList();
  }

  void addNote(Note note) {
    _noteBox.put(note.id, note);
    notifyListeners();
  }

  void updateNote(Note updatedNote) {
    _noteBox.put(updatedNote.id, updatedNote);
    notifyListeners();
  }

  void deleteNote(String noteId) {
    _noteBox.delete(noteId);
    notifyListeners();
  }
}