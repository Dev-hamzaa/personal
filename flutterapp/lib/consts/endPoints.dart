class Endpoints {
  static String register = '${baseUrl}api/auth/register';
  static String login = '${baseUrl}api/auth/login';
  static String getDoctors = '${baseUrl}api/doctor/getDoctors';
  static String getPatients = '${baseUrl}api/patient/getPatients';
  static String getAppointments = '${baseUrl}api/appointment/getAppointments';
  static String getPrescriptions = '${baseUrl}api/prescription/getPrescriptions';

  static String baseUrl = 'http://192.168.0.106:4000/';
}


