import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../DataBase/Mongodb.dart';

class MailProcess {
  List<String> questions = <String>[];
  List<List<double>> performanceData = <List<double>>[];
  Map<String, dynamic> userdata = {};
  List<String> recipientmail=<String>[];
  List<String> ccmail=<String>[];
  List<String> bccmail=<String>[];


  void individualEmail(List<String> questions,
    List<List<double>> performanceData, Map<String, dynamic> data) async {
    userdata = data;
    this.performanceData = performanceData;
    this.questions = questions;

    try {
      // Check and request storage permission
      if (await checkAndRequestPermissions()) {
        // Generate the PDF file
        String filePath = await generatePdf(this.performanceData);

        // Send the generated file via email
        await sendEmail(filePath);
      } else {
        print('Necessary permissions denied');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> checkAndRequestPermissions() async {
    // Request permissions for accessing media files
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    // Check if all media permissions are granted
    bool allMediaPermissionsGranted = statuses.values
        .every((status) => status.isGranted);

    // Request Manage External Storage permission if needed
    PermissionStatus storageStatus = await Permission.manageExternalStorage.request();

    if (allMediaPermissionsGranted && storageStatus.isGranted) {
      return true;
    } else {
      if (!allMediaPermissionsGranted) {
        print('One or more media permissions denied');
      }
      if (!storageStatus.isGranted) {
        print('Manage External Storage permission denied');
      }
      if (storageStatus.isPermanentlyDenied) {
        print('Manage External Storage permission permanently denied');
        openAppSettings();
      }
      return false;
    }
  }

  Future<String> getFilePath(String fileName) async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      return "${directory.path}/$fileName";
    } else {
      throw Exception('Directory not found');
    }
  }

  Future<String> generatePdf(List<List<double>> data) async {
    final pdf = pw.Document();

    // Load the font
    final fontBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final fontRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Regular.ttf'));

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Employee information section
              pw.Padding(
                padding: pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                            'Date: ${DateTime.now().toString().split(" ")[0]}',
                            style:
                                pw.TextStyle(font: fontRegular, fontSize: 12)),
                      ],
                    ),
                    pw.SizedBox(
                        height:
                            10), // Add space between date and employee details
                    pw.Text('Employee Name: ${userdata['name']}',
                        style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.Text('Employee ID: ${userdata['id']}',
                        style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.Text('Employee Position: ${userdata['position']}',
                        style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.SizedBox(
                        height: 20), // Add space between the info and the table
                  ],
                ),
              ),
              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        color: PdfColors.grey300,
                        alignment: pw.Alignment.center,
                        child: pw.Text('Question',
                            style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        color: PdfColors.grey300,
                        alignment: pw.Alignment.center,
                        child: pw.Text('Performance',
                            style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ),
                    ],
                  ),
                  ...List<pw.TableRow>.generate(data[0].length, (index) {
                    return pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(questions[index],
                              textAlign: pw.TextAlign.left,
                              style:
                                  pw.TextStyle(font: fontRegular, fontSize: 8)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(5),
                          color: data[0][index] == 1
                              ? PdfColors.green
                              : PdfColors.red,
                          alignment: pw.Alignment.center,
                          child: pw.Text(data[0][index] == 1 ? 'YES' : 'NO',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  font: fontRegular, fontSize: 10)),
                        ),
                      ],
                    );
                  }),
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('TOTAL SCORE',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(5),
                        alignment: pw.Alignment.center,
                        child: pw.Text(data[1][0].toString(),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(font: fontBold, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Get the file path
    String outputPath = await getFilePath(
        "${userdata['name'].toString() + DateTime.now().toString().split(" ")[0]}.pdf");
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
    print('PDF file generated at: $outputPath');

    return outputPath;
  }

  Future<void> sendEmail(String filePath) async {
    String username = 'kln.jeyashree@gmail.com'; // Replace with your email
    String password = 'tbou fdfv mnph ykfy'; // Replace with your email password

    recipientmail=await MongoDatabase.get_Com("recipientmail");
    // ccmail=await MongoDatabase.get_Com("ccmail");
    // bccmail=await MongoDatabase.get_Com("bccmail");

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Jayashree')
      ..recipients.addAll(recipientmail) // Replace with recipient's email
      // ..ccRecipients.addAll(ccmail)
      // ..bccRecipients.addAll(bccmail)
      ..subject = 'Daily Individual Performance Report'
      ..text = 'Please find the attached performance report.'
      ..attachments.add(FileAttachment(File(filePath)));

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Message not sent.');
      print(e.toString());
    }
  }
}
