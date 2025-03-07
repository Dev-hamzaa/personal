const User = require("../../model/user");

const patientList = async (req, reply) => {
  try {
    const { name } = req.query;
    // let query = { userRole: "patient" };
    if (name) {
      query = {
        ...query,
        name: {
          $regex: new RegExp(name, "i"),
        },
      };
    }
    const list = await User.find(query);
    return reply.json({
      success: true,
      message: "Patients List",
      data: list,
    });
  } catch (error) {
    return reply.json({
      message: "internal server Error",
      data: error.message,
    });
  }
};

const getpatientDetail = async (req, reply) => {
  try {
    const { id } = req.params;
    const patientDetail = await User.findById({
      _id: id,
    });

    if (!patientDetail) {
      return reply.json({
        success: false,
        message: "patient Not found",
      });
    }
    console.log("Patient Detail ");
    return reply.json({
      success: true,
      message: "patient Detail",
      data: patientDetail,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

const deletePatient = async (req, reply) => {
  try {
    const { id } = req.params;
    const delPatient = await User.findByIdAndDelete({
      _id: id,
    });
    if (!delPatient) {
      return reply.json({
        success: false,
        message: "Patient not found",
      });
    }
    return reply.json({
      success: true,
      message: "Patient Deleted",
      data: delPatient,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

const updatePatient = async (req, reply) => {
  try {
    const { id } = req.params;
    const { name, phone } = req.body;
    console.log(req.body);
    const updatePatient = await User.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        name,
        phone: phone,
      },
      {
        new: true,
      }
    );
    return reply.json({
      success: true,
      messsage: "patient updated ",
      data: updatePatient,
    });
  } catch (error) {
    console.log(error);
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

module.exports = {
  updatePatient,
  patientList,
  getpatientDetail,
  deletePatient,
};
