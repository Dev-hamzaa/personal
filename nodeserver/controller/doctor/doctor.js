const User = require("../../model/user");
const { DateTime } = require("luxon");

const createDoctor = async (req, reply) => {
  try {
    const { name, email, password, specialization } = req.body;
    const foundDoctor = await User.findOne({
      email: email,
    });
    if (foundDoctor) {
      return reply.json({
        success: false,
        message: "Your email is already registered",
      });
    }
    const newDoctor = await User.create({
      name: name,
      password: password,
      email: email,
      specialization: specialization,
    });
    return reply.json({
      success: true,
      message: "Doctor Signup successfully",
    });
  } catch (error) {
    return reply.json({
      message: "internal server Error",
      data: error.message,
    });
  }
};

const doctorList = async (req, reply) => {
  try {
    const { name } = req.query;
    let query = { userRole: "doctor" };
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

const doctorDetail = async (req, reply) => {
  try {
    const { id } = req.params;
    const docDetail = await User.findById(id);

    if (!docDetail) {
      return reply.json({
        success: false,
        message: "Doctor not found",
      });
    }
    console.log(docDetail?.profilePic);
    const formattedSchedule =
      docDetail.weeklySchedule?.map(({ day, start, end }) => {
        return {
          day,
          start: DateTime.fromJSDate(start).toFormat("hh:mm a"),
          end: DateTime.fromJSDate(end).toFormat("hh:mm a"),
        };
      }) || [];

    return reply.json({
      success: true,
      message: "Doctor Detail",
      data: {
        ...docDetail.toObject(), // Convert Mongoose document to plain object
        weeklySchedule: formattedSchedule, // Replace raw dates with formatted schedule
      },
    });
  } catch (error) {
    console.error(error);

    return reply.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const deleteDoctor = async (req, reply) => {
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

const updateDoctor = async (req, reply) => {
  try {
    const { id } = req.params;
    const { name, email, specialization, phone, weeklySchedule, rating } =
      req.body;
    console.log(req.body);
    console.log(req.file);
    // Check if doctor exists
    const foundDoctor = await User.findById(id);
    if (!foundDoctor) {
      return reply.json({
        success: false,
        message: "Doctor not found",
      });
    }
    let formattedSchedule;
    // Convert time strings to Date objects
    if (weeklySchedule) {
      formattedSchedule = JSON.parse(weeklySchedule)?.map(
        ({ day, start, end }) => ({
          day,
          start: DateTime.fromFormat(start, "hh:mm a").toJSDate(),
          end: DateTime.fromFormat(end, "hh:mm a").toJSDate(),
        })
      );
    }

    // Update doctor in DB
    const updatedDoctor = await User.findByIdAndUpdate(
      id, // Pass ID directly instead of `{ _id: id }`
      {
        name: name ? name : foundDoctor.name,
        email: email ? email : foundDoctor,
        specialization: specialization
          ? specialization
          : foundDoctor.specialization,
        phone: phone ? phone : foundDoctor.phone,
        weeklySchedule: weeklySchedule
          ? formattedSchedule
          : foundDoctor.weeklySchedule,
        profilePic: req.file ? req.file.path : foundDoctor.profilePic,
        rating: rating ? rating : foundDoctor.rating,
      },
      { new: true }
    );

    // if (req.file) {
    //   await User.findByIdAndUpdate(
    //     id, // Pass ID directly instead of `{ _id: id }`
    //     {
    //       profilePic: req.file ?? req.file.path,
    //     },
    //     { new: true }
    //   );
    // }

    return reply.json({
      success: true,
      message: "Doctor updated",
      data: updatedDoctor,
    });
  } catch (error) {
    console.error(error);
    return reply.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

const patchdoctor = async (req, reply) => {
  try {
    const { id } = req.params;
    const { rating } = req.body;
    const userId = req.query.userId; // Assuming user ID is available in `req.user`

    const foundDoctor = await User.findById(id);
    if (!foundDoctor) {
      return reply.json({
        success: false,
        message: "Doctor not found",
      });
    }

    let existingRating = foundDoctor.ratedBy.find(
      (r) => r.userId.toString() === userId
    );

    if (existingRating) {
      // Update existing rating
      existingRating.rating = rating;
    } else {
      // Add new rating entry
      foundDoctor.ratedBy.push({ userId, rating });
    }

    // Recalculate average rating
    const totalRatings = foundDoctor.ratedBy.length;
    const newAverageRating =
      foundDoctor.ratedBy.reduce((sum, r) => sum + r.rating, 0) / totalRatings;

    foundDoctor.rating = newAverageRating;
    await foundDoctor.save();

    return reply.json({
      success: true,
      message: "Doctor rating updated",
      data: foundDoctor,
    });
  } catch (error) {
    console.error(error);
    return reply.json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

module.exports = {
  updateDoctor,
  deleteDoctor,
  doctorDetail,
  doctorList,
  patchdoctor,
};
