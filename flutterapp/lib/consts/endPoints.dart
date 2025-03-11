class Endpoints {
  static String register = '${baseUrl}api/auth/register';
  static String login = '${baseUrl}api/auth/login';
  static String getAllDoctors = '${baseUrl}api/doctor/';
  static String getDoctorDetails = '${baseUrl}api/doctor';
  static String getAllPatients = '${baseUrl}api/patient/';
  static String getPatientDetails = '${baseUrl}api/patient';
  static String getAppointments = '${baseUrl}api/appoint/';
  static String bookAppointment = '${baseUrl}api/appoint/';
  static String getPrescriptions =
      '${baseUrl}api/prescription/getPrescriptions';
  static String getAllDonors = '${baseUrl}api/donor/';

  static String baseUrl = 'http://192.168.0.106:8000/';
  // static String baseUrl = 'http://192.168.3.219:4000/';
}
