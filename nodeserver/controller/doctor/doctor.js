import { User } from "../../model/user.js";

export const doctorList = async (req, reply) => {
  try {
    const { name } = req.query;
    let query = { userRole: "doctor" };
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
      message: "Doctors List",
      data: list,
    });
  } catch (error) {
    return reply.json({
      message: "internal server Error",
      data: error.message,
    });
  }
};

export const doctorDetail = async (req, reply) => {
  try {
    const { id } = req.params;
    const docDetail = await User.findById({
      _id: id,
    });

    if (!docDetail) {
      return reply.json({
        success: false,
        message: "doctor Not found",
      });
    }
    return reply.json({
      success: true,
      message: "Doctor Detail",
      data: docDetail,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

export const deleteDoctor = async (req, reply) => {
  try {
    const { id } = req.params;
    const delDoctor = await User.findByIdAndDelete({
      _id: id,
    });
    if (!delDoctor) {
      return reply.json({
        success: false,
        message: "Doctor not found",
      });
    }
    return reply.json({
      success: true,
      message: "Doctor Deleted",
      data: delDoctor,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

export const updateDoctor = async (req, reply) => {
  try {
    const { id } = req.params;
    const { firstName, lastName, specialization, phoneNumber } = req.body;
    const updatedDoctor = await User.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        firstName,
        lastName,
        specialization,
        phoneNumber,
      },
      {
        new: true,
      }
    );
    return reply.json({
      success: true,
      messsage: "Doctor updated ",
      data: updatedDoctor,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};
