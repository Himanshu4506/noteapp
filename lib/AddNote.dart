import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddNote extends StatefulWidget {
  final bool isUpdate;
  final String? title;
  final String? desc;
  final int? sno;

  AddNote({this.isUpdate = false, this.title, this.desc, this.sno});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  String? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserId();

    if (widget.isUpdate) {
      titleController.text = widget.title ?? "";
      descController.text = widget.desc ?? "";
    }
  }

  /// 🔹 Load user id
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('id');
  }

  /// 🔹 ADD NOTE API
  Future<void> addNoteApi() async {
    if (userId == null) return;

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.212.236.184/noteapp/AddNote.php");

    try {
      final response = await http.post(
        url,
        body: {
          "user_id": userId!,
          "title": titleController.text.trim(),
          "description": descController.text.trim(),
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Note Added Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Server Error")));
    }

    setState(() => isLoading = false);
  }

  Future<void> updateNoteApi() async {
    if (widget.sno == null) return;

    setState(() => isLoading = true);

    final url = Uri.parse("http://192.168.1.3/noteapp/UpdateNote.php");

    try {
      final response = await http.post(
        url,
        body: {
          "id": widget.sno.toString(),
          "title": titleController.text.trim(),
          "description": descController.text.trim(),
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Note Updated Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Server Error")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isUpdate ? "Update Note" : "Add Note",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title*",
                  hintText: "Enter Note Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 20),

              TextField(
                controller: descController,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: "Description*",
                  hintText: "Enter Note Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          var title = titleController.text.trim();
                          var desc = descController.text.trim();

                          if (title.isEmpty || desc.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please fill all fields"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (widget.isUpdate) {
                            updateNoteApi();
                          } else {
                            addNoteApi();
                          }
                        },
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isUpdate ? "Update Note" : "Add Note",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
