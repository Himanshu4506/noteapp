import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AddNote.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List allNotes = [];
  String? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  /// 🔹 Load user id
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
    getNotesApi();
  }

  /// 🔹 Get Notes API
  Future<void> getNotesApi() async {
    if (userId == null) return;

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.212.236.184/noteapp/datashow.php");

    try {
      final response = await http.post(url, body: {"user_id": userId!});

      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        allNotes = data['data'];
      } else {
        allNotes = [];
      }
    } catch (e) {
      allNotes = [];
    }

    setState(() => isLoading = false);
  }

  /// 🔹 Delete Note API
  Future<void> deleteNoteApi(String noteId) async {
    final url = Uri.parse("http://10.212.236.184/noteapp/DeleteNote.php");
    await http.post(url, body: {"id": noteId});
    getNotesApi();
  }

  /// 🔹 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  void confirmDelete(String noteId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              deleteNoteApi(noteId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _noteCard(Map note, int index) {
    final title = (note["title"] ?? "").toString();
    final desc = (note["desc"] ?? "").toString();
    final id = (note["id"] ?? "").toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddNote(
                  isUpdate: true,
                  sno: int.parse(id),
                  title: title,
                  desc: desc,
                ),
              ),
            ).then((value) {
              if (value == true) getNotesApi();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Index badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                /// Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Delete button
                IconButton(
                  onPressed: () => confirmDelete(id),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  splashRadius: 22,
                  tooltip: "Delete",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.note_alt_outlined, size: 70, color: Colors.red),
            SizedBox(height: 12),
            Text(
              "No Notes Yet!!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              "Tap on 'Add Note' to create your first note.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        automaticallyImplyLeading: false, //  removes back button
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "All Notes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: logout,
                tooltip: "Logout",
              ),
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: getNotesApi,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : allNotes.isNotEmpty
            ? ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: allNotes.length,
                itemBuilder: (_, index) {
                  final note = (allNotes[index] as Map).cast<String, dynamic>();
                  return _noteCard(note, index);
                },
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: 200), _emptyState()],
              ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddNote(isUpdate: false)),
          ).then((value) {
            if (value == true) getNotesApi();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Note"),
      ),
    );
  }
}
