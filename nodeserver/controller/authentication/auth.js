import { User } from "../../model/user";

export const register = async (req, reply) => {
  try {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    const {
      firstName,
      lastName,
      email,
      password,
      userRole,
      phoneNumber,
      bloodType,
      specialization,
    } = req.body;
    if (!firstName || !lastName || !password || (!email && !phoneNumber)) {
      return reply
        .status(400)
        .send({ success: false, message: "Required fields are missing" });
    }
    //CHECK EMAIL
    if (email) {
      if (!emailRegex.test(email.toLowerCase().trim())) {
        return reply
          .status(400)
          .send({ success: false, message: "Email is not valid" });
      }
      //CHECK DUPLICATION
      const duplicateUser = await User.findOne({
        email: email,
      });
      if (duplicateUser) {
        return reply
          .status(400)
          .send({ success: false, message: "Email  already exists" });
      }
    }
    const newUser = await User.create({
      firstName: firstName,
      lastName: lastName,
      userRole: userRole,
      password: password,
      email: email,
      bloodType: bloodType,
      specialization: specialization,
    });
    return reply.send({
      success: true,
      message: "Created SuccessFully",
      data: newUser,
    });
  } catch (err) {
    return reply.status(500).send({
      message: "Internal Server Error",
      error: err.message,
    });
  }
};

export const login = async (req, reply) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return reply
      .status(400)
      .send({ success: false, message: MESSAGE.INVALID_CREDENTIALS });
  }
  try {
    const user = await User.findOne({
      email: email,
      password: password,
    }).select("+password");
    if (!user) {
      return reply
        .status(400)
        .send({ success: false, message: MESSAGE.INVALID_CREDENTIALS });
    }
    // if (user.userRole !== "admin" && user.userRole !== "staff") {
    //     return next(new ErrorResponse(MESSAGE.ACCESS_DENIED, 400));
    // }

    return reply.status(200).send({
      success: true,
      message: "Login Successfully",
      data: user,
    });
  } catch (err) {
    return reply.status(500).send({
      message: "Internal Server Error",
      error: err.message,
    });
  }
};
