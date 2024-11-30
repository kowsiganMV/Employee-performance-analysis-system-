import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class WeekMail {
  void scheduleEmail() async {
    List<List<List<int>>> performanceData = [
      [
        [1, 0, 1, 1, 0, 0, 1],  
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
      [
        [1, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
      [
        [1, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
      [
        [1, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
      [
        [1, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
      [
        [1, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
      [
        [1, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0, 1],
        [1, 0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 1, 1],
        [1, 1, 0, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 1, 1],
        [1, 0, 0, 1, 0, 1, 1],
        [0, 1, 1, 0, 1, 0, 0],
        [5, 5, 6, 5, 6, 6, 5],
      ],
    ];

    try {
      // Generate the PDF file
      String filePath = await generatePdf(performanceData);

      // Send the generated file via email
      await sendEmail(filePath);
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to generate the PDF file
  Future<String> generatePdf(List<List<List<int>>> allData) async {
    final pdf = pw.Document();

    // Sample questions
    List<String> questions = [
      "Question 1",
      "Question 2",
      "Question 3",
      "Question 4",
      "Question 5",
      "Question 6",
      "Question 7",
      "Question 8",
      "Question 9",
      "Question 10",
      "Total"
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return List<pw.Widget>.generate(allData.length, (workerIndex) {
            List<List<int>> data = allData[workerIndex];
            return pw.Container(
              margin: pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Worker ${workerIndex + 1}'),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('S.no', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Questions', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Monday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Tuesday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Wednesday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Thursday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Friday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Saturday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Sunday', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.all(3),
                            color: PdfColors.grey300,
                            child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                          ),
                        ],
                      ),
                      ...List<pw.TableRow>.generate(questions.length, (index) {
                        if (index == questions.length - 1) {
                          return pw.TableRow(
                            children: [
                              pw.Container(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('${index + 1}', textAlign: pw.TextAlign.center),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(questions[index]),
                              ),
                              ...data[index].map((value) {
                                return pw.Container(
                                  padding: pw.EdgeInsets.all(3),
                                  child: pw.Text('$value', textAlign: pw.TextAlign.center),
                                );
                              }).toList(),
                              pw.Container(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(''),
                              ),
                            ],
                          );
                        } else {
                          final totalYes = data[index].where((value) => value == 1).length;

                          return pw.TableRow(
                            children: [
                              pw.Container(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('${index + 1}', textAlign: pw.TextAlign.center),
                              ),
                              pw.Container(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text(questions[index]),
                              ),
                              ...data[index].map((value) {
                                return pw.Container(
                                  padding: pw.EdgeInsets.all(3),
                                  color: value == 1 ? PdfColors.green : PdfColors.red,
                                  child: pw.Text(value == 1 ? 'YES' : 'NO', textAlign: pw.TextAlign.center),
                                );
                              }).toList(),
                              pw.Container(
                                padding: pw.EdgeInsets.all(3),
                                child: pw.Text('$totalYes', textAlign: pw.TextAlign.center),
                              ),
                            ],
                          );
                        }
                      }),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ),
    );

    // Get the directory to save the PDF file
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String outputPath = '$appDocPath/EmployeeAppraisal.pdf';

    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());

    print('PDF file generated at: $outputPath');

    return outputPath;
  }

  Future<void> sendEmail(String filePath) async {
    String username = 'nickolatesla963@gmail.com'; // Replace with your email
    String password = 'wkkt yymv qxto rmkl'; // Replace with your email password

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Your Name')
      ..recipients.add('kln.jeyashree@gmail.com') // Replace with recipient's email
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
