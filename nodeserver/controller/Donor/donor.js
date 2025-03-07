const User = require("../../model/user");

const donorList = async (req, res, next) => {
  try {
    const { name } = req.query;
    let query = { userRole: "donor" };
    if (name) {
      query = {
        ...query,
        name: {
          $regex: new RegExp(name, "i"),
        },
      };
    }
    const list = await User.find(query);
    return res.json({
      success: true,
      message: "Donors List",
      data: list,
    });
  } catch (error) {
    return res.json({
      message: "internal server Error",
      data: error.message,
    });
  }
};

const getDonorDetail = async (req, reply) => {
  try {
    const { id } = req.params;
    const patientDetail = await User.findById({
      _id: id,
    });

    if (!patientDetail) {
      return reply.json({
        success: false,
        message: "Donor Not found",
      });
    }
    return reply.json({
      success: true,
      message: "Donor Detail",
      data: patientDetail,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

const deleteDonor = async (req, reply) => {
  try {
    const { id } = req.params;
    const delPatient = await User.findByIdAndDelete({
      _id: id,
    });
    if (!delPatient) {
      return reply.json({
        success: false,
        message: "Donor not found",
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

const updateDonor = async (req, reply) => {
  try {
    const { id } = req.params;
    const { name, phone, selectedOrgan, bloodType } = req.body;
    const updatePatient = await User.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        name,
        phone,
        bloodType,
        selectedOrgan,
      },
      {
        new: true,
      }
    );
    return reply.json({
      success: true,
      messsage: "Donor updated ",
      data: updatePatient,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};
module.exports = { donorList, getDonorDetail, deleteDonor, updateDonor };
