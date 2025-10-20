
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wateera/providers/auth_provider.dart';
import '../models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AuthProvider _authProvider;

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NoteProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    _fetchNotes();
  }

  CollectionReference get _notesCollection => _firestore
      .collection('users')
      .doc(_authProvider.user!.uid)
      .collection('notes');

  Future<void> _fetchNotes() async {
    if (_authProvider.user == null) return;

    _notesCollection.snapshots().listen((snapshot) {
      _notes = snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  List<Note> getNotesForDate(DateTime date) {
    return _notes.where((note) {
      return note.createdAt.year == date.year &&
          note.createdAt.month == date.month &&
          note.createdAt.day == date.day;
    }).toList();
  }

  Future<void> addNote(Note note) async {
    if (_authProvider.user == null) return;
    await _notesCollection.doc(note.id).set(note.toJson());
  }

  Future<void> updateNote(Note updatedNote) async {
    if (_authProvider.user == null) return;
    await _notesCollection.doc(updatedNote.id).update(updatedNote.toJson());
  }

  Future<void> deleteNote(String noteId) async {
    if (_authProvider.user == null) return;
    await _notesCollection.doc(noteId).delete();
  }
}
