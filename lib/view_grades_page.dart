import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewGradesPage extends StatefulWidget {
  const ViewGradesPage({super.key});

  @override
  State<ViewGradesPage> createState() => _ViewGradesPageState();
}

class _ViewGradesPageState extends State<ViewGradesPage> {

  List grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGrades();
  }

  Future fetchGrades() async {

    final url = Uri.parse("http://localhost/evaltrack_api/view_grades.php");

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if(data["success"]){
      setState(() {
        grades = data["data"];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Student Grades"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(

        itemCount: grades.length,

        itemBuilder: (context, index) {

          final g = grades[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(

              title: Text(
                  "${g["first_name"]} ${g["last_name"]}"
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Student No: ${g["student_no"]}"),
                  Text("Program: ${g["program"]}"),
                  Text("Subject: ${g["subject_code"]} - ${g["subject_name"]}"),
                  Text("Grade: ${g["grade"]}"),
                  Text("Semester: ${g["semester"]}"),
                  Text("School Year: ${g["school_year"]}"),

                ],
              ),

            ),
          );
        },

      ),
    );
  }
}