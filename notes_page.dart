import 'package:flutter/material.dart';
import 'package:flutter_app/add_edit_note_page.dart';
import 'package:flutter_app/note.dart';
import 'package:flutter_app/note_card_widget.dart';
import 'package:flutter_app/note_detail_page.dart';
import 'package:flutter_app/notes_database.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: TextStyle(fontSize: 24),),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 12,)
        ],
      ),
      body: Center(
        child: isLoading ? CircularProgressIndicator()
            : notes.isEmpty
            ? Text(
            'No notes', style: TextStyle(color: Colors.white, fontSize: 24))
            : _buildNotes(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditNotePage()));
          refreshNotes();
        },
      ),
    );
  }

  Widget _buildNotes() {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!)));
            refreshNotes();
          },
          child: NoteCardWidget(note: note, index: index),
        );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
      itemCount: notes.length,
      padding: EdgeInsets.all(8),
    );
  }

  Future refreshNotes() async {
    setState(() {
      isLoading = true;
    });
    this.notes = await NotesDatabase.instance.readAllNotes();
    setState(() {
      isLoading = false;
    });
  }
}
