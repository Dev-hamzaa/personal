import { User } from "../../model/user.js";

export const patientList = async (req, reply) => {
  try {
    const { name } = req.query;
    let query = { userRole: "patient" };
    if (name) {
      query = {
        ...query,
        firstName: {
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

export const getpatientDetail = async (req, reply) => {
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

export const deletePatient = async (req, reply) => {
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

export const updatePatient = async (req, reply) => {
  try {
    const { id } = req.params;
    const { firstName, lastName, emergencyNumber, phoneNumber } = req.body;
    const updatePatient = await User.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        firstName,
        lastName,
        emergencyNumber,
        phoneNumber,
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
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};
