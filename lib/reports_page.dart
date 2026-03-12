import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String program = "BSIT";
  String schoolYear = "2025-2026";
  String semester = "1st";

  bool loading = false;
  String error = "";
  List<dynamic> rows = [];

  // IMPORTANT: Flutter Web calls localhost via browser.
  // If this fails, we will switch to: http://127.0.0.1/evaltrack_api/reports.php
  final String baseUrl = "http://127.0.0.1/evaltrack_api/reports.php";

  Future<void> loadReports() async {
    setState(() {
      loading = true;
      error = "";
      rows = [];
    });

    try {
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          "program": program,
          "school_year": schoolYear,
          "semester": semester,
        },
      );

      final res = await http.get(uri);
      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        setState(() => rows = data["data"]);
      } else {
        setState(() => error = data["message"] ?? "Unknown error");
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadReports(); // auto load on open
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filters (Client request): Program, School Year, Semester",
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DropdownButton<String>(
                  value: program,
                  items: const [
                    DropdownMenuItem(value: "BSIT", child: Text("BSIT")),
                    DropdownMenuItem(value: "BSEMC", child: Text("BSEMC")),
                  ],
                  onChanged: (v) => setState(() => program = v ?? "BSIT"),
                ),
                DropdownButton<String>(
                  value: schoolYear,
                  items: const [
                    DropdownMenuItem(
                      value: "2025-2026",
                      child: Text("2025-2026"),
                    ),
                    DropdownMenuItem(
                      value: "2024-2025",
                      child: Text("2024-2025"),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => schoolYear = v ?? "2025-2026"),
                ),
                DropdownButton<String>(
                  value: semester,
                  items: const [
                    DropdownMenuItem(value: "1st", child: Text("1st Semester")),
                    DropdownMenuItem(value: "2nd", child: Text("2nd Semester")),
                  ],
                  onChanged: (v) => setState(() => semester = v ?? "1st"),
                ),
                ElevatedButton(
                  onPressed: loading ? null : loadReports,
                  child: const Text("Apply"),
                ),
              ],
            ),

            const SizedBox(height: 16),
            if (loading) const LinearProgressIndicator(),
            if (error.isNotEmpty)
              Text("Error: $error", style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),

            Expanded(
              child: rows.isEmpty
                  ? const Text("No data yet.")
                  : ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (_, i) {
                        final r = rows[i];
                        return Card(
                          child: ListTile(
                            title: Text(
                              "${r["student_name"]} (${r["student_no"]})",
                            ),
                            subtitle: Text(
                              "${r["program"]} | ${r["school_year"]} ${r["semester"]} | ${r["subject_code"]}",
                            ),
                            trailing: Text("${r["grade"]}"),
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
