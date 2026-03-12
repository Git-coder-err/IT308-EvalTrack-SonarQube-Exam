import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'student_details_page.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List allStudents = [];
  List filteredStudents = [];
  bool isLoading = true;
  String errorMessage = "";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final url = Uri.parse("http://localhost/evaltrack_api/students_list.php");

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          allStudents = data["data"];
          filteredStudents = List.from(allStudents);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data["message"] ?? "Unknown error";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  void filterStudents(String query) {
    setState(() {
      searchQuery = query;
      filteredStudents = allStudents.where((student) {
        final studentName = student["student_name"].toString().toLowerCase();
        final studentNo = student["student_no"].toString().toLowerCase();
        final program = student["program"].toString().toLowerCase();
        final q = query.toLowerCase();

        return studentName.contains(q) ||
            studentNo.contains(q) ||
            program.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student List"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Student List / Details",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Search and open a student record.",
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Search student name, student number, or program",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: filterStudents,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Showing ${filteredStudents.length} student(s)",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];

                            return Card(
                              child: ListTile(
                                title: Text(student["student_name"].toString()),
                                subtitle: Text(
                                  "Student No: ${student["student_no"]} | Program: ${student["program"]}",
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StudentDetailsPage(
                                          studentId: int.parse(student["id"].toString()),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("View Details"),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}