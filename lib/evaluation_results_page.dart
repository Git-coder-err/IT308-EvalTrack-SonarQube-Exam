import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EvaluationResultsPage extends StatefulWidget {
  const EvaluationResultsPage({super.key});

  @override
  State<EvaluationResultsPage> createState() => _EvaluationResultsPageState();
}

class _EvaluationResultsPageState extends State<EvaluationResultsPage> {
  List allResults = [];
  List filteredResults = [];
  bool isLoading = true;
  String errorMessage = "";

  String searchQuery = "";
  String selectedProgram = "All";
  String selectedSemester = "All";
  String selectedSchoolYear = "All";

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvaluationResults();
  }

  Future<void> fetchEvaluationResults() async {
    final url = Uri.parse(
      "http://localhost/evaltrack_api/evaluation_results.php",
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          allResults = data["data"];
          filteredResults = List.from(allResults);
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

  void applyFilters() {
    List temp = List.from(allResults);

    if (searchQuery.isNotEmpty) {
      temp = temp.where((row) {
        final studentName = row["student_name"].toString().toLowerCase();
        final studentNo = row["student_no"].toString().toLowerCase();
        final query = searchQuery.toLowerCase();

        return studentName.contains(query) || studentNo.contains(query);
      }).toList();
    }

    if (selectedProgram != "All") {
      temp = temp.where((row) {
        return row["program"].toString() == selectedProgram;
      }).toList();
    }

    if (selectedSemester != "All") {
      temp = temp.where((row) {
        return row["semester"].toString() == selectedSemester;
      }).toList();
    }

    if (selectedSchoolYear != "All") {
      temp = temp.where((row) {
        return row["school_year"].toString() == selectedSchoolYear;
      }).toList();
    }

    setState(() {
      filteredResults = temp;
    });
  }

  Color getEvaluationColor(String result) {
    if (result.toUpperCase() == "PASSED") {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  List<String> getUniqueValues(String key) {
    final values = allResults.map((row) => row[key].toString()).toSet().toList();
    values.sort();
    return ["All", ...values];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programOptions = getUniqueValues("program");
    final semesterOptions = getUniqueValues("semester");
    final schoolYearOptions = getUniqueValues("school_year");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Evaluation Results"),
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
                        "Student Evaluation Table",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Search and filter student evaluation results.",
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: "Search student name or student number",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          searchQuery = value;
                          applyFilters();
                        },
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedProgram,
                              decoration: const InputDecoration(
                                labelText: "Program",
                                border: OutlineInputBorder(),
                              ),
                              items: programOptions.map((program) {
                                return DropdownMenuItem(
                                  value: program,
                                  child: Text(program),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedProgram = value!;
                                applyFilters();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedSemester,
                              decoration: const InputDecoration(
                                labelText: "Semester",
                                border: OutlineInputBorder(),
                              ),
                              items: semesterOptions.map((semester) {
                                return DropdownMenuItem(
                                  value: semester,
                                  child: Text(semester),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedSemester = value!;
                                applyFilters();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedSchoolYear,
                              decoration: const InputDecoration(
                                labelText: "School Year",
                                border: OutlineInputBorder(),
                              ),
                              items: schoolYearOptions.map((schoolYear) {
                                return DropdownMenuItem(
                                  value: schoolYear,
                                  child: Text(schoolYear),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedSchoolYear = value!;
                                applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Showing ${filteredResults.length} result(s)",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowColor: WidgetStatePropertyAll(
                                Colors.grey.shade300,
                              ),
                              columns: const [
                                DataColumn(label: Text("Student No")),
                                DataColumn(label: Text("Student Name")),
                                DataColumn(label: Text("Program")),
                                DataColumn(label: Text("Subject Code")),
                                DataColumn(label: Text("Subject Name")),
                                DataColumn(label: Text("Grade")),
                                DataColumn(label: Text("Remarks")),
                                DataColumn(label: Text("Semester")),
                                DataColumn(label: Text("School Year")),
                                DataColumn(label: Text("Evaluation Result")),
                              ],
                              rows: filteredResults.map<DataRow>((row) {
                                final evalResult =
                                    row["evaluation_result"].toString();

                                return DataRow(
                                  cells: [
                                    DataCell(Text(row["student_no"].toString())),
                                    DataCell(Text(row["student_name"].toString())),
                                    DataCell(Text(row["program"].toString())),
                                    DataCell(Text(row["subject_code"].toString())),
                                    DataCell(Text(row["subject_name"].toString())),
                                    DataCell(Text(row["grade"].toString())),
                                    DataCell(Text(row["remarks"].toString())),
                                    DataCell(Text(row["semester"].toString())),
                                    DataCell(Text(row["school_year"].toString())),
                                    DataCell(
                                      Text(
                                        evalResult,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: getEvaluationColor(evalResult),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}