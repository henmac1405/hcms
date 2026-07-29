import 'package:flutter/material.dart';
import 'app_colors.dart';
// import 'user_session.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  // Contoh data dinamis request approval (bisa dihubungkan ke API nanti)
  final List<Map<String, dynamic>> _approvalRequests = [
    {
      'type': 'CUTI',
      'subject': 'Umroh',
      'submitted_by': 'Ari Prasasti',
      'employee_id': 'CT000081',
      'status': 'Pending',
    },
    {
      'type': 'PERJALANAN DINAS',
      'subject': 'Opening Frozenland',
      'submitted_by': 'Ari Prasasti',
      'employee_id': 'CT000081',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA), // Background abu-abu muda bersih
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER UTAMA: Warna Navy
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.accent, // Warna navy gelap sesuai gambar
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Workflows & Approvals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Role: Employee View (My Requests)',
                  style: TextStyle(
                    color:
                        AppColors.primary, // Warna oranye/emas teks sub-header
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 2. KONTEN DENGAN SCROLL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // KOTAK INFORMASI / BANNER INFO BIRU MURA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFE8F0FE), // Background biru sangat muda
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info,
                          color: Color(0xFF001668),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Di sini Anda dapat memantau status pengajuan cuti, sakit, izin perjalanan dinas, dan koreksi absensi. Ketuk kartu untuk melihat komentar atau dokumen.',
                            style: TextStyle(
                              color: Colors.blueGrey.shade800,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LIST CARD APPROVAL (Dinamis menggunakan data List di atas)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _approvalRequests.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = _approvalRequests[index];
                      return _buildApprovalCard(item);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET KUSTOM UNTUK MEMBUAT KARTU APPROVAL
  Widget _buildApprovalCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        // Aksi ketika kartu diklik (misal pergi ke detail dokumen)
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten Teks Sebelah Kiri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['type'],
                    style: const TextStyle(
                      color: Color(0xFF001668),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Subject: ${item['subject']}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted by: ${item['submitted_by']}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '(${item['employee_id']})',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Badge Status "Pending" Sebelah Kanan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0), // Background orange muda soft
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item['status'],
                style: const TextStyle(
                  color: Color(0xFFFD8A02), // Text warna orange tajam asli
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
