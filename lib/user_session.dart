import 'dart:io';

class UserSession {
  UserSession._();

  // Ubah dari static const menjadi static String biasa agar nilainya bisa diisi ulang
  static String company_id = "";
  static String company_name = "";
  static String employee_id = "";
  static String employee_name = "";
  static String employee_personalid = "";
  static String employee_fingerid = "";
  static String employee_type = "";
  static String office_id = "";
  static String office_name = "";
  static String employee_gender = "";
  static String employee_dateofbirth = "";
  static String divisi_name = "";
  static String database_name = "";
  static String device_info = "";
  static String shift_id = "";
  static String department_name = "";
  static String url_api = "";
  static String url_api_slide = "";
  static String url_api_image = "";
  static String url_api_prod = "";
  static String url_api_slide_prod = "";
  static String url_api_image_prod = "";
  static String url_api_dev = "";
  static String url_api_slide_dev = "";
  static String url_api_image_dev = "";
  static String employee_phone = "";
  static String apikey = "";
  static String token = "";
  static String listcompany_id = "";
  static String debug = "";
  static File? profile_image_file;
  static String profile_image_url = "";
  static String employee_password = "";

  static String employee_address1 = "";
  static String employee_address2 = "";
  static String employee_bpjs = "";
  static String employee_entrydate = "";
  static String employeetype_name = "";
  static String employeeeducation_level = "";
  static String employee_dob = "";
  static String employee_joindate = "";
  static String position_name = "";
  static String url_api_lokal = "";

  static String url_api_part1 = "";
  static String url_api_part2 = "";
  static String url_api_dev_part1 = "";
  static String url_api_image_part1 = "";
  static String url_api_image_part2 = "";
  static String url_api_image_dev_part1 = "";
  static String url_image_profile_part1 = "";
  static String url_image_profile_part2 = "";
  static String url_image_profile_dev_part1 = "";
  static String url_image_profile = "";
  static int userlevel = 0;
  static String image_idcard = "";
  static String employeeeducation_name = "";
  // Fungsi utilitas untuk mengisi data secara massal setelah login berhasil
  static void login(
      {required String company_id_,
      required String company_name_,
      required String employee_id_,
      required String employee_name_,
      required String employee_personalid_,
      required String employee_fingerid_,
      required String employee_type_,
      required String office_id_,
      required String office_name_,
      required String employee_gender_,
      required String employee_dateofbirth_,
      required String divisi_name_,
      required String database_name_,
      required String device_info_,
      required String shift_id_,
      required String department_name_,
      required String url_api_,
      required String url_api_slide_,
      required String url_api_image_,
      required String url_api_prod_,
      required String url_api_slide_prod_,
      required String url_api_image_prod_,
      required String url_api_dev_,
      required String url_api_slide_dev_,
      required String url_api_image_dev_,
      required String employee_phone_,
      required String apikey_,
      required String token_,
      required String listcompany_id_,
      required String debug_,
      required File? profile_image_file_,
      required String profile_image_url_,
      required String employee_password_,
      required String employee_address1_,
      required String employee_address2_,
      required String employee_bpjs_,
      required String employee_entrydate_,
      required String employeetype_name_,
      required String employeeeducation_level_,
      required String employee_dob_,
      required String employee_joindate_,
      required String position_name_,
      required String url_api_lokal_,
      required String url_api_part1_,
      required String url_api_part2_,
      required String url_api_dev_part1_,
      required String url_api_image_part1_,
      required String url_api_image_part2_,
      required String url_api_image_dev_part1_,
      required String url_image_profile_part1_,
      required String url_image_profile_part2_,
      required String url_image_profile_dev_part1_,
      required String url_image_profile_,
      required int userlevel_,
      required String image_idcard_,
      required String employeeeducation_name_}) {
    company_id = company_id_;
    company_name = company_name_;
    employee_id = employee_id_;
    employee_name = employee_name_;
    employee_personalid = employee_personalid_;
    employee_fingerid = employee_fingerid_;
    employee_type = employee_type_;
    office_id = office_id_;
    office_name = office_name_;
    employee_gender = employee_gender_;
    employee_dateofbirth = employee_dateofbirth_;
    divisi_name = divisi_name_;
    database_name = database_name_;
    device_info = device_info_;
    shift_id = shift_id_;
    department_name = department_name_;
    url_api = url_api_;
    url_api_slide = url_api_slide_;
    url_api_image = url_api_image_;
    url_api_prod = url_api_prod_;
    url_api_slide_prod = url_api_slide_prod_;
    url_api_image_prod = url_api_image_prod_;
    url_api_dev = url_api_dev_;
    url_api_slide_dev = url_api_slide_dev_;
    url_api_image_dev = url_api_image_dev_;
    employee_phone = employee_phone_;
    apikey = apikey_;
    token = token_;
    listcompany_id = listcompany_id_;
    debug = debug_;
    profile_image_file = profile_image_file_;
    profile_image_url = profile_image_url_;
    employee_password = employee_password_;

    employee_address1 = employee_address1_;
    employee_address2 = employee_address2_;
    employee_bpjs = employee_bpjs_;
    employee_entrydate = employee_entrydate_;
    employeetype_name = employeetype_name_;
    employeeeducation_level = employeeeducation_level_;
    employee_dob = employee_dob_;
    employee_joindate = employee_joindate_;
    position_name = position_name_;
    url_api_lokal = url_api_lokal_;
    url_api_part1 = url_api_part1_;
    url_api_part2 = url_api_part2_;
    url_api_dev_part1 = url_api_dev_part1_;
    url_api_image_part1 = url_api_image_part1_;
    url_api_image_part2 = url_api_image_part2_;
    url_api_image_dev_part1 = url_api_image_dev_part1_;
    url_image_profile_part1 = url_image_profile_part1_;
    url_image_profile_part2 = url_image_profile_part2_;
    url_image_profile_dev_part1 = url_image_profile_dev_part1_;
    url_image_profile = url_image_profile_;
    userlevel = userlevel_;
    image_idcard = image_idcard_;
    employeeeducation_name = employeeeducation_name_;
  }

  // Fungsi utilitas untuk membersihkan data saat logout
  static void clear() {
    company_id = "";
    company_name = "";
    employee_id = "";
    employee_name = "";
    employee_personalid = "";
    employee_fingerid = "";
    employee_type = "";
    office_id = "";
    office_name = "";
    employee_gender = "";
    employee_dateofbirth = "";
    divisi_name = "";
    database_name = "";
    device_info = "";
    shift_id = "";
    department_name = "";
    url_api = "";
    url_api_slide = "";
    url_api_image = "";
    url_api_prod = "";
    url_api_slide_prod = "";
    url_api_image_prod = "";
    url_api_dev = "";
    url_api_slide_dev = "";
    url_api_image_dev = "";
    employee_phone = "";
    apikey = "";
    token = "";
    listcompany_id = "";
    debug = "";
    profile_image_file = null;
    profile_image_url = "";
    employee_password = "";
    employee_address1 = "";
    employee_address2 = "";
    employee_bpjs = "";
    employee_entrydate = "";
    employeetype_name = "";
    employeeeducation_level = "";
    employee_dob = "";
    employee_joindate = "";
    position_name = "";
    url_api_lokal = "";
    url_api_part1 = "";
    url_api_part2 = "";
    url_api_dev_part1 = "";
    url_api_image_part1 = "";
    url_api_image_part2 = "";
    url_api_image_dev_part1 = "";
    url_image_profile_part1 = "";
    url_image_profile_part2 = "";
    url_image_profile_dev_part1 = "";
    url_image_profile = "";
    userlevel = 0;
    image_idcard = "";
    employeeeducation_name = "";
  }
}
