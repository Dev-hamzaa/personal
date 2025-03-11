const { Appointment } = require("../../model/appointment");

const createAppointment = async (req, res, next) => {
  try {
    const { doctorId, patientId, appointmentDate, time } = req.body;
    console.log(req.body);

    const newAppointment = await Appointment.create({
      doctorId: doctorId,
      patientId: patientId,
      appointmentDate: appointmentDate,
      time: time,
    });
    return res.json({
      success: true,
      message: "Appointment Booked",
      data: newAppointment,
    });
  } catch (error) {
    console.log(error);

    return res.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const getAppointmentDetail = async (req, res, next) => {
  try {
    const { id } = req.params;
    const found = await Appointment.findById({
      _id: id,
    });
    return res.json({
      success: true,
      message: "Appointment Detail",
      data: found,
    });
  } catch (error) {
    return res.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const getAppointments = async (req, res, next) => {
  try {
    const { doctor, patient, date } = req.query;
    let query = {}; // Start with an empty query

    // Add conditions only if they exist in the request
    if (doctor) {
      query.doctorId = doctor;
    }
    if (patient) {
      query.patientId = patient;
    }
    if (date) {
      query.appointmentDate = new Date(date);
    }
    console.log(query);

    const found = await Appointment.find(query)
      .populate({
        path: "doctorId",
        select: { _id: 1, name: 1, specialization: 1, profilePic: 1 },
      })
      .populate({
        path: "patientId",
        select: { _id: 1, name: 1, email: 1, profilePic: 1 },
      })
      .sort({ createdAt: -1 });
    console.log(found);
    return res.json({
      success: true,
      message: "Appointment Listing",
      data: found,
    });
  } catch (error) {
    return res.status(500).json({
      // Use correct status code for server errors
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const updateAppoitment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { doctorId, patientId, appointmentDate, status, time } = req.body;
    const updateAppointment = await Appointment.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        doctorId: doctorId,
        patientId: patientId,
        appointmentDate: appointmentDate,
        status: status,
        time: time,
      }
    );
    return res.json({
      success: true,
      message: "Appointment Updated",
      data: updateAppointment,
    });
  } catch (error) {
    console.log(error);
    return res.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const delAppointment = async (req, res, next) => {
  try {
    const { id } = req.params;
    const newAppointment = await Appointment.findByIdAndDelete({
      _id: id,
    });
    return res.json({
      success: true,
      message: "Appointment deleted",
      data: newAppointment,
    });
  } catch (error) {
    return res.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// const updateAppoitment = async (req, res, next) => {
//   try {
//     const { doctorId, patientId, appointmentDate, status } = req.body;
//     const updateAppointment = await Appointment.create({
//       doctorId: doctorId,
//       patientId: patientId,
//       appointmentDate: appointmentDate,
//       status: status,
//       time: time,
//     });
//     return res.json({
//       success: true,
//       message: "Appointment Updated",
//       data: updateAppointment,
//     });
//   } catch (error) {
//     return res.json({
//       success: false,
//       message: "Internal server error",
//       error: error.message,
//     });
//   }
// };

module.exports = {
  createAppointment,
  getAppointmentDetail,
  getAppointments,
  updateAppoitment,
  delAppointment,
};
