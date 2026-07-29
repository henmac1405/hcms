import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'user_session.dart';
import 'package:hcms/database/function_helper.dart';
import 'loginnew.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  HelperFunction fh = new HelperFunction();
  // Controller untuk menangani input teks
  final _userController =
      TextEditingController(text: UserSession.employee_personalid);
  final _oldPasswordController = TextEditingController(text: '');
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State untuk kontrol visibilitas password (show/hide)
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void simpanpasswordbaru() {
    setState(() {
      isLoading = true;
    });
    fh
        .changepassword(
            UserSession.employee_personalid,
            _oldPasswordController.text,
            _newPasswordController.text,
            UserSession.apikey,
            UserSession.token,
            "absen/changePassword",
            UserSession.url_api)
        .then((result) {
      setState(() {
        isLoading = false;
      });
      print("Change : " + result);
      if (result.substring(0, 6) == "sukses") {
        _showSnackBar(result, Colors.green);

        Route route = MaterialPageRoute<void>(
            builder: (context) => LoginNewPage(
                url_api_part1: UserSession.url_api_part1,
                url_api_part2: UserSession.url_api_part2,
                url_api_dev_part1: UserSession.url_api_dev_part1,
                url_api_image_part1: UserSession.url_api_image_part1,
                url_api_image_part2: UserSession.url_api_image_part2,
                url_api_image_dev_part1: UserSession.url_api_image_dev_part1,
                url_image_profile_part1: UserSession.url_image_profile_part1,
                url_image_profile_part2: UserSession.url_image_profile_part2,
                url_image_profile_dev_part1:
                    UserSession.url_image_profile_dev_part1,
                url_api_slide: UserSession.url_api_slide,
                url_api_lokal: UserSession.url_api_lokal,
                debug: UserSession.debug));
        Navigator.push<void>(context, route);
      } else {
        _showSnackBar(result, Colors.red);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA), // Background abu-abu muda bersih

      // ==================== APP BAR ====================
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary, // Navy (#001668)
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: const Row(
      //     children: [
      //       const Text(
      //         'Ubah Password',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 20,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

      body: Column(
        children: [
          // 1. Indikator Loading Bar (Hanya muncul jika isLoading bernilai true)
          if (isLoading == true)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFF1F1F1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 4, // Ketebalan garis progress
            ),

          // Memberikan jarak tipis jika sedang loading
          if (isLoading == true) const SizedBox(height: 10),

          // 2. Konten Utama yang Bisa Di-scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: AppColors
                        .accent, // Mengatur warna latar belakang menjadi Oranye
                    alignment: Alignment
                        .center, // Berfungsi sama seperti widget Center untuk menaruh konten di tengah
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Membuat teks berada di tengah horizontal
                      children: [
                        Text(
                          'UBAH PASSWORD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  // ==================== CARD 1: EDUKASI KEAMANAN ====================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.02 * 255).round()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2275),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Perbarui password akun Anda secara\nberkala demi keamanan data.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== CARD 2: INFORMASI AKUN & FORM INPUT ====================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.02 * 255).round()),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: AppColors.accent, // Orange (#fd8a02)
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Informasi Akun',
                              style: TextStyle(
                                color: Color(0xFF0F1E4A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // FIELD 1: User (Read-Only)
                        _buildLabelForm('User Name'),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F2F6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          child: Text(
                            _userController.text,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // FIELD 2: Password Lama
                        _buildLabelForm('Password Lama'),
                        _buildPasswordField(
                          controller: _oldPasswordController,
                          hintText: 'Masukkan password lama',
                          obscureText: _obscureOldPassword,
                          readonly: false,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureOldPassword = !_obscureOldPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // FIELD 3: Password Baru
                        _buildLabelForm('Password Baru'),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: 'Minimal 8 karakter',
                          obscureText: _obscureNewPassword,
                          readonly: false,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // FIELD 4: Ulangi Password Baru
                        _buildLabelForm('Konfirmasi Password Baru'),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Ketik ulang password baru',
                          obscureText: _obscureConfirmPassword,
                          readonly: false,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ==================== INFORMASI FOOTER VALIDASI ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF001F82),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Password baru minimal 8 karakter, kombinasi huruf besar, huruf kecil & angka. Sistem akan memverifikasi password lama dan mencocokkan konfirmasi sebelum menyimpan perubahan.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ==================== TOMBOL UTAMA: SIMPAN PASSWORD BARU ====================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        String passwordLama = _oldPasswordController.text;
                        String passwordBaru = _newPasswordController.text;
                        String konfirmasiPassword =
                            _confirmPasswordController.text;
// 2. Validasi input tidak boleh ada yang kosong
                        if (passwordLama.isEmpty ||
                            passwordBaru.isEmpty ||
                            konfirmasiPassword.isEmpty) {
                          _showSnackBar(
                              "Semua kolom password wajib diisi!", Colors.red);
                          return;
                        }

                        // 3. Validasi Panjang Minimal 8 Karakter
                        if (passwordBaru.length < 8) {
                          _showSnackBar(
                              "Password baru harus minimal 8 karakter!",
                              Colors.red);
                          return;
                        }

                        // 4. Validasi Kombinasi: Huruf Besar, Huruf Kecil, dan Angka (Menggunakan RegEx)
                        // [A-Z] = harus ada huruf besar
                        // [a-z] = harus ada huruf kecil
                        // [0-9] = harus ada angka

                        // RegExp regexHurufBesar = RegExp(r'[A-Z]');
                        // RegExp regexHurufKecil = RegExp(r'[a-z]');
                        // RegExp regexAngka = RegExp(r'[0-9]');

                        // if (!regexHurufBesar.hasMatch(passwordBaru)) {
                        //   _showSnackBar(
                        //       "Password baru harus mengandung minimal 1 huruf besar (A-Z)!",
                        //       Colors.red);
                        //   return;
                        // }

                        // if (!regexHurufKecil.hasMatch(passwordBaru)) {
                        //   _showSnackBar(
                        //       "Password baru harus mengandung minimal 1 huruf kecil (a-z)!",
                        //       Colors.red);
                        //   return;
                        // }

                        // if (!regexAngka.hasMatch(passwordBaru)) {
                        //   _showSnackBar(
                        //       "Password baru harus mengandung minimal 1 angka (0-9)!",
                        //       Colors.red);
                        //   return;
                        // }

                        // 5. Validasi Kecocokan Konfirmasi Password Baru
                        if (passwordBaru != konfirmasiPassword) {
                          _showSnackBar("Konfirmasi password baru tidak cocok!",
                              Colors.red);
                          return;
                        }

                        // 6. Validasi Password Baru Tidak Boleh Sama dengan Password Lama
                        if (passwordLama == passwordBaru) {
                          _showSnackBar(
                              "Password baru tidak boleh sama dengan password lama!",
                              Colors.red);
                          return;
                        }

                        simpanpasswordbaru();
                      },
                      icon: const Icon(Icons.check_circle,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Simpan Password Baru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.accent, // Orange Accent (#fd8a02)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelForm(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F1E4A),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool readonly,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readonly,
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF0F1E4A),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
              fontWeight: FontWeight.w400),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF7A869A),
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  _showDialog(String keterangan) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              //padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(
                keterangan,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color.fromARGB(255, 2, 8, 134),
                fontSize: 16.0,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String pesan, Color warnaBg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warnaBg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
