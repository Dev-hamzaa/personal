const { donorRequest } = require("../../model/donorRequest");
const createRequest = async (req, res, next) => {
  try {
    const { donorId, patientId, requestedOrgan, bloodType } = req.body;
    console.log(req.body);

    const foundRequest = await donorRequest.findOne({
      patientId: patientId,
      requestedOrgan: requestedOrgan,
    });

    if (foundRequest) {
      return res.json({
        success: false,
        message: "The requets is already placed",
      });
    }

    const newAppointment = await donorRequest.create({
      donorId: donorId,
      patientId: patientId,
      requestedOrgan: requestedOrgan,
      bloodType: bloodType,
      bloodOnly: requestedOrgan === "" ? true : false,
    });
    return res.json({
      success: true,
      message: "Request sent",
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

const getRequestDetail = async (req, res, next) => {
  try {
    const { id } = req.params;
    const found = await donorRequest.findById({
      _id: id,
    });
    return res.json({
      success: true,
      message: "Request Detail",
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

const getRequests = async (req, res, next) => {
  try {
    const { donor, patientId, requestedOrgan, status, blood, patient,donorblood } =
      req.query;
    // console.log("heere", patientId);

    let query = {}; // Start with an empty query

    // Add conditions only if they exist in the request

    if (donor) {
      query.donorId = donor;
    }
    if (patientId) {
      query.patientId = patientId;
    }
    if (requestedOrgan) {
      query.requestedOrgan = requestedOrgan;
    }
    if (status) {
      query.status = status;
    }
    if (blood && patient === true) {
      query.bloodOnly = true;
    }

     console.log(typeof donorblood)
    if(donorblood==="true"){
      query.bloodOnly = true;

    }
     else {
      query.bloodOnly = false;
    }
    console.log(query);

    const found = await donorRequest
      .find(query)
      .populate({
        path: "donorId",
        select: { _id: 1, name: 1, email: 1, profilePic: 1 },
      })
      .populate({
        path: "patientId",
        select: { _id: 1, name: 1, email: 1, profilePic: 1 },
      })
      .sort({ createdAt: -1 });
    // console.log(found);
    return res.json({
      success: true,
      message: "donorRequesting Listing",
      data: found,
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({
      // Use correct status code for server errors
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const getPatientRequest = async (req, res, next) => {
  try {
    const { patientId } = req.query;
    // console.log("heere", patientId);

    let query = {}; // Start with an empty query

    // Add conditions only if they exist in the request

    // if (donor) {
    //   query.donorId = donor;
    // }
    if (patientId) {
      query.patientId = patientId;
    }
    // if (requestedOrgan) {
    //   query.requestedOrgan = requestedOrgan;
    // }
    // if (status) {
    //   query.status = status;
    // }
    // if (blood && patient === true) {
    //   query.bloodOnly = true;
    // } else {
    //   query.bloodOnly = false;
    // }
    // console.log(query);

    const found = await donorRequest
      .find(query)
      .populate({
        path: "donorId",
        select: { _id: 1, name: 1, email: 1, profilePic: 1 },
      })
      .populate({
        path: "patientId",
        select: { _id: 1, name: 1, email: 1, profilePic: 1 },
      })
      .sort({ createdAt: -1 });
    console.log(found);
    return res.json({
      success: true,
      message: "donorRequesting Listing",
      data: found,
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({
      // Use correct status code for server errors
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const updateRequest = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { donorId, patientId, requestedOrgan, bloodType, status } = req.body;
    const updateAppointment = await donorRequest.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        donorId: donorId,
        patientId: patientId,
        requestedOrgan: requestedOrgan,
        status: status,
      }
    );
    return res.json({
      success: true,
      message: "Donor Request Updated",
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

const delRequest = async (req, res, next) => {
  try {
    const { id } = req.params;
    const newAppointment = await donorRequest.findByIdAndDelete({
      _id: id,
    });
    return res.json({
      success: true,
      message: "Donor Request deleted",
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
  createRequest,
  getRequestDetail,
  getPatientRequest,
  getRequests,
  updateRequest,
  delRequest,
};
