import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wateera/providers/auth_provider.dart';
import 'package:wateera/providers/user_provider.dart';
import 'package:wateera/services/notification_service.dart';
import '../models/note_model.dart';

const int NOTE_BONUS_POINTS = 5; // Define bonus points for adding a note

class NoteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  late AuthProvider _authProvider;
  UserProvider? _userProvider;

  List<Note> _notes = [];

  List<Note> get notes => _notes;

  NoteProvider(AuthProvider authProvider, [List<Note>? initialNotes]) {
    _authProvider = authProvider;
    _notes = initialNotes ?? [];
    _fetchNotes();
  }

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider.user != null) {
      _fetchNotes();
    } else {
      _notes = [];
    }
    notifyListeners();
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
    await _notificationService.showNotification(
      'New Note Added',
      'You have a new note: ${note.title}',
    );
    
    // Award XP for adding a note
    if (_userProvider != null) {
      await _userProvider!.awardNoteXP();
    }
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
