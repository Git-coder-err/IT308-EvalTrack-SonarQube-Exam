import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StudentDetailsPage extends StatefulWidget {
  final int studentId;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  bool loading = true;
  String error = '';

  Map<String, dynamic> student = {};
  List<Map<String, dynamic>> gradeRecords = [];

  final String apiUrl = "http://127.0.0.1/evaltrack_api/student_details.php";

  @override
  void initState() {
    super.initState();
    loadStudentDetails();
  }

  Future<void> loadStudentDetails() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {
          "student_id": widget.studentId.toString(),
        },
      );

      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final dynamic dataPart = data["data"];

        Map<String, dynamic> studentMap = {};
        List<Map<String, dynamic>> recordsList = [];

        if (data["student"] != null) {
          studentMap = Map<String, dynamic>.from(data["student"]);
        } else if (dataPart is Map && dataPart["student"] != null) {
          studentMap = Map<String, dynamic>.from(dataPart["student"]);
        }

        final dynamic rawRecords =
            data["grades"] ??
            data["records"] ??
            (dataPart is Map ? dataPart["grades"] ?? dataPart["records"] : null);

        if (rawRecords is List) {
          recordsList = rawRecords
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }

        setState(() {
          student = studentMap;
          gradeRecords = recordsList;
          loading = false;
        });
      } else {
        setState(() {
          error = data["message"]?.toString() ?? "Failed to load student details.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        loading = false;
      });
    }
  }

  String get fullName {
    final firstName = student["first_name"]?.toString() ?? "";
    final lastName = student["last_name"]?.toString() ?? "";
    final wholeName = "$firstName $lastName".trim();

    if (wholeName.isNotEmpty) return wholeName;
    return student["student_name"]?.toString() ?? "Student";
  }

  String get studentNo => student["student_no"]?.toString() ?? "-";
  String get program => student["program"]?.toString() ?? "-";

  double? _parseGrade(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  bool _isPassed(Map<String, dynamic> record) {
    final grade = _parseGrade(record["grade"]);
    if (grade == null) return false;
    return grade >= 75;
  }

  int get totalSubjects => gradeRecords.length;

  int get passedSubjects =>
      gradeRecords.where((record) => _isPassed(record)).length;

  int get failedSubjects =>
      gradeRecords.where((record) => !_isPassed(record)).length;

  double get averageGrade {
    if (gradeRecords.isEmpty) return 0;

    double sum = 0;
    int count = 0;

    for (final record in gradeRecords) {
      final grade = _parseGrade(record["grade"]);
      if (grade != null) {
        sum += grade;
        count++;
      }
    }

    if (count == 0) return 0;
    return sum / count;
  }

  String get overallStanding {
    if (gradeRecords.isEmpty) return "No Records";
    if (failedSubjects == 0) return "Regular / Passed";
    return "Needs Review";
  }

  Widget summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.purple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }

  Color _remarksColor(Map<String, dynamic> record) {
    return _isPassed(record) ? Colors.green : Colors.red;
  }

  String _remarksText(Map<String, dynamic> record) {
    return _isPassed(record) ? "Passed" : "Failed";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A148C),
        title: const Text(
          "Student Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header inspired by registrar sheet
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jose Maria College Foundation, Inc.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Student Curriculum Evaluation",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Student No: $studentNo",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Program: $program",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.1,
                        children: [
                          summaryCard(
                            icon: Icons.menu_book,
                            title: "Total Subjects",
                            value: totalSubjects.toString(),
                            color: Colors.deepPurple,
                          ),
                          summaryCard(
                            icon: Icons.check_circle,
                            title: "Passed",
                            value: passedSubjects.toString(),
                            color: Colors.green,
                          ),
                          summaryCard(
                            icon: Icons.cancel,
                            title: "Failed",
                            value: failedSubjects.toString(),
                            color: Colors.red,
                          ),
                          summaryCard(
                            icon: Icons.school,
                            title: "Average Grade",
                            value: averageGrade == 0
                                ? "-"
                                : averageGrade.toStringAsFixed(2),
                            color: Colors.pink,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purple.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fact_check,
                              color: Color(0xFF6A1B9A),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Overall Standing:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: failedSubjects == 0
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                overallStanding,
                                style: TextStyle(
                                  color: failedSubjects == 0
                                      ? Colors.green
                                      : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Grade Records",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "This section is styled to resemble the school’s curriculum evaluation sheet.",
                        style: TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purple.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: gradeRecords.isEmpty
                            ? const Text("No grade records found.")
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.grey.shade200,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text("Subject Code")),
                                    DataColumn(label: Text("Subject Name")),
                                    DataColumn(label: Text("Grade")),
                                    DataColumn(label: Text("Remarks")),
                                    DataColumn(label: Text("Semester")),
                                    DataColumn(label: Text("School Year")),
                                  ],
                                  rows: gradeRecords.map((record) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            record["subject_code"]?.toString() ?? "-",
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            record["subject_name"]?.toString() ?? "-",
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            record["grade"]?.toString() ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _remarksText(record),
                                            style: TextStyle(
                                              color: _remarksColor(record),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            record["semester"]?.toString() ?? "-",
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            record["school_year"]?.toString() ?? "-",
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}