import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> allSubjects = [];
  List<dynamic> filteredSubjects = [];
  bool loading = true;
  String error = "";

  String selectedProgram = "All";
  String selectedYearLevel = "All";
  String selectedSemester = "All";

  final String apiUrl = "http://127.0.0.1/evaltrack_api/subjects_list.php";

  @override
  void initState() {
    super.initState();
    loadSubjects();
    _searchController.addListener(filterSubjects);
  }

  Future<void> loadSubjects() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          allSubjects = data["data"];
          filteredSubjects = data["data"];
          loading = false;
        });
        filterSubjects();
      } else {
        setState(() {
          error = data["message"] ?? "Failed to load subjects";
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

  void filterSubjects() {
  final query = _searchController.text.toLowerCase().trim();

  setState(() {
    filteredSubjects = allSubjects.where((subject) {
      final code = (subject["subject_code"] ?? "").toString().toLowerCase();
      final name = (subject["subject_name"] ?? "").toString().toLowerCase();
      final program = (subject["program"] ?? "").toString();
      final yearLevel = (subject["year_level"] ?? "").toString();
      final semester = (subject["semester"] ?? "").toString();

      bool matchesSearch = true;

      if (query.isNotEmpty) {
        matchesSearch =
            code.startsWith(query) ||
            name.split(' ').any((word) => word.startsWith(query)) ||
            program.toLowerCase().startsWith(query) ||
            yearLevel.toLowerCase().startsWith(query) ||
            semester.toLowerCase().startsWith(query);
      }

      final matchesProgram =
          selectedProgram == "All" || program == selectedProgram;

      final matchesYearLevel =
          selectedYearLevel == "All" || yearLevel == selectedYearLevel;

      final matchesSemester =
          selectedSemester == "All" || semester == selectedSemester;

      return matchesSearch &&
          matchesProgram &&
          matchesYearLevel &&
          matchesSemester;
    }).toList();
  });
}

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE6C3F1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 15, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 24,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE6C3F1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE6C3F1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFF9C27B0),
              width: 1.5,
            ),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Curriculum / Subjects",
          style: TextStyle(
            color: Color(0xFF5A189A),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5A189A)),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jose Maria College Foundation, Inc.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Curriculum / Subject Reference Sheet",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFEADCF2),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Subjects Registry",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "This module lists available subject codes, titles, units, schedules, and prerequisite references currently stored in EvalTrack.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFEADCF2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          statCard(
                            title: "Total Subjects",
                            value: "${allSubjects.length}",
                            icon: Icons.menu_book_rounded,
                            iconColor: const Color(0xFF6F42C1),
                            iconBg: const Color(0xFFF1E8FF),
                          ),
                          const SizedBox(width: 16),
                          statCard(
                            title: "Filtered Results",
                            value: "${filteredSubjects.length}",
                            icon: Icons.filter_alt_rounded,
                            iconColor: const Color(0xFFE91E63),
                            iconBg: const Color(0xFFFFE4EF),
                          ),
                          const SizedBox(width: 16),
                          statCard(
                            title: "Programs Supported",
                            value: "BSIT / BSEMC",
                            icon: Icons.school_rounded,
                            iconColor: const Color(0xFF4CAF50),
                            iconBg: const Color(0xFFE7F4EA),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        "Subjects Search",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A189A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Search by subject code, subject title, program, year level, or semester.",
                        style: TextStyle(color: Color(0xFF555555)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              "Search subject code, subject title, program, year level, or semester",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6C3F1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6C3F1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: Color(0xFF9C27B0),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          buildDropdown(
                            label: "Program",
                            value: selectedProgram,
                            items: const ["All", "BSIT", "BSEMC"],
                            onChanged: (value) {
                              selectedProgram = value!;
                              filterSubjects();
                            },
                          ),
                          const SizedBox(width: 12),
                          buildDropdown(
                            label: "Year Level",
                            value: selectedYearLevel,
                            items: const [
                              "All",
                              "1st Year",
                              "2nd Year",
                              "3rd Year",
                              "4th Year",
                            ],
                            onChanged: (value) {
                              selectedYearLevel = value!;
                              filterSubjects();
                            },
                          ),
                          const SizedBox(width: 12),
                          buildDropdown(
                            label: "Semester",
                            value: selectedSemester,
                            items: const [
                              "All",
                              "1st Semester",
                              "2nd Semester",
                              "Summer",
                            ],
                            onChanged: (value) {
                              selectedSemester = value!;
                              filterSubjects();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Showing ${filteredSubjects.length} subject(s)",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE6C3F1)),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 28,
                            headingRowColor: WidgetStateProperty.all(
                              const Color(0xFFF1F1F1),
                            ),
                            columns: const [
                              DataColumn(label: Text("Subject Code")),
                              DataColumn(label: Text("Subject Name")),
                              DataColumn(label: Text("Program")),
                              DataColumn(label: Text("Year Level")),
                              DataColumn(label: Text("Semester")),
                              DataColumn(label: Text("Units")),
                              DataColumn(label: Text("Lec")),
                              DataColumn(label: Text("Lab")),
                              DataColumn(label: Text("Prerequisite")),
                              DataColumn(label: Text("Status")),
                            ],
                            rows: filteredSubjects.map((subject) {
                              final prereq =
                                  (subject["prerequisite_code"] ?? "")
                                      .toString()
                                      .trim();

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      "${subject["subject_code"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text("${subject["subject_name"]}")),
                                  DataCell(Text("${subject["program"]}")),
                                  DataCell(Text("${subject["year_level"]}")),
                                  DataCell(Text("${subject["semester"]}")),
                                  DataCell(Text("${subject["units"]}")),
                                  DataCell(Text("${subject["lec_hours"]}")),
                                  DataCell(Text("${subject["lab_hours"]}")),
                                  DataCell(Text(prereq.isEmpty ? "-" : prereq)),
                                  const DataCell(
                                    Text(
                                      "Active",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8EFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE6C3F1)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Next Planned Upgrade",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5A189A),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "The next version of this module will include curriculum grouping by program, year level, and semester so it can match the official curriculum evaluation format more closely.",
                              style: TextStyle(color: Color(0xFF444444)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}