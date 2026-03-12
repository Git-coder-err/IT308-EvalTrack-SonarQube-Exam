import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadGradesPage extends StatefulWidget {
  const UploadGradesPage({super.key});

  @override
  State<UploadGradesPage> createState() => _UploadGradesPageState();
}

class _UploadGradesPageState extends State<UploadGradesPage> {
  final String studentsApiUrl = "http://127.0.0.1/evaltrack_api/students_list.php";
  final String uploadApiUrl = "http://127.0.0.1/evaltrack_api/upload_grades_file.php";

  List<dynamic> students = [];
  Map<String, dynamic>? selectedStudent;
  PlatformFile? selectedFile;

  bool isLoadingStudents = true;
  bool isUploading = false;
  String? message;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoadingStudents = true;
      message = null;
    });

    try {
      final response = await http.get(Uri.parse(studentsApiUrl));
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        setState(() {
          students = data["data"];
          isLoadingStudents = false;
        });
      } else {
        setState(() {
          isLoadingStudents = false;
          message = "Failed to load students.";
          isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingStudents = false;
        message = "Error loading students: $e";
        isSuccess = false;
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "png", "pdf"],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
        message = null;
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedStudent == null) {
      setState(() {
        message = "Please select a student first.";
        isSuccess = false;
      });
      return;
    }

    if (selectedFile == null) {
      setState(() {
        message = "Please choose a file first.";
        isSuccess = false;
      });
      return;
    }

    if (selectedFile!.bytes == null) {
      setState(() {
        message = "Selected file data is empty.";
        isSuccess = false;
      });
      return;
    }

    setState(() {
      isUploading = true;
      message = null;
    });

    try {
      final request = http.MultipartRequest("POST", Uri.parse(uploadApiUrl));

      request.fields["student_id"] = selectedStudent!["id"].toString();
      request.fields["uploaded_by"] = "inst1";

      request.files.add(
        http.MultipartFile.fromBytes(
          "grade_file",
          selectedFile!.bytes!,
          filename: selectedFile!.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      setState(() {
        isUploading = false;
        message = data["message"] ?? "Upload finished.";
        isSuccess = data["success"] == true;
      });

      if (data["success"] == true) {
        setState(() {
          selectedFile = null;
          selectedStudent = null;
        });
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        message = "Upload failed: $e";
        isSuccess = false;
      });
    }
  }

  Widget buildTopCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jose Maria College Foundation, Inc.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Upload Grades Module",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 18),
          Text(
            "Upload Report of Grades / Evaluation File",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "This module allows instructors to upload a file for a selected student before OCR extraction and evaluation.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUploadForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7C8F1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upload Form",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select a student and upload a JPG, PNG, or PDF file.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          if (isLoadingStudents)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            )
          else
            DropdownButtonFormField<Map<String, dynamic>>(
              value: selectedStudent,
              decoration: InputDecoration(
                labelText: "Select Student",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: students.map<DropdownMenuItem<Map<String, dynamic>>>((student) {
                final label =
                    "${student["student_no"]} - ${student["student_name"]} (${student["program"]})";
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: student,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStudent = value;
                });
              },
            ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8B4E2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selected File",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedFile == null
                      ? "No file selected yet."
                      : selectedFile!.name,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Choose File"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isUploading ? null : uploadFile,
                      icon: const Icon(Icons.cloud_upload),
                      label: Text(isUploading ? "Uploading..." : "Upload File"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (message != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSuccess ? Colors.green : Colors.redAccent,
                ),
              ),
              child: Text(
                message!,
                style: TextStyle(
                  color: isSuccess ? Colors.green.shade800 : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7C8F1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F0F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A148C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Upload Grades",
          style: TextStyle(
            color: Color(0xFF4A148C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTopCard(),
            const SizedBox(height: 22),

            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: 320,
                  child: buildInfoCard(
                    icon: Icons.description_outlined,
                    title: "Allowed Files",
                    subtitle: "JPG, JPEG, PNG, PDF",
                    color: const Color(0xFF7C3AED),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: buildInfoCard(
                    icon: Icons.auto_awesome,
                    title: "Next Step",
                    subtitle: "OCR extraction will be added after upload.",
                    color: const Color(0xFFEC4899),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: buildInfoCard(
                    icon: Icons.school_outlined,
                    title: "Target Use",
                    subtitle: "Instructor uploads grade files per student.",
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            buildUploadForm(),
          ],
        ),
      ),
    );
  }
}