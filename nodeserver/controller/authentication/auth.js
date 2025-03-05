const User = require("../../model/user");
const jsonWebToken=require('jsonwebtoken')
const register = async (req, reply) => {
  try {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    console.log(req.body)
    const {
    name  ,
    email,
      password,
      userRole,
      // phoneNumber,
      bloodType,
      specialization,
      organType
    } = req.body;
    console.log(req.body)
    if (!name ||  !password || !email  ||!userRole) {
      return reply
        .status(400)
        .send({ success: false, message: "Required fields are missing" });
    }
    //CHECK EMAIL
    if (email) {
      if (!emailRegex.test(email.toLowerCase().trim())) {
        return reply
          .status(400)
          .json({ success: false, message: "Email is not valid" });
      }
      //CHECK DUPLICATION
      const duplicateUser = await User.findOne({
        email: email,
      });
      if (duplicateUser) {
        return reply
          .status(400)
          .json({ success: false, message: "Email  already exists" });
      }
    }
    const newUser = await User.create({
      name: name,
      userRole: userRole,
      password: password,
      email: email,
      bloodType: bloodType,
      specialization: specialization,
      selectedOrgan:organType
    });
    console.log(newUser)
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


 const login = async (req, reply) => {
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
    const token=jwtToken(user)
    console.log(user)
    return reply.status(200).send({
      success: true,
      message: "Login Successfully",
      // token:token,
      data: user,
    });
  } catch (err) {
    return reply.status(500).send({
      message: "Internal Server Error",
      error: err.message,
    });
  }
};
const protectedRoute=async(req,res)=>{
  try {
    return reply.json(
      {
        succes:true
      }
    )
  } catch (error) {
    return reply.status(500).send({
      message: "Internal Server Error",
      error: err.message,
    });
  }
}

 const jwtToken = (user) => {
  // console.log(process.env.JWT_SECRET_KEY)

  return jsonWebToken.sign(
    {
        id: user.id,
        userRole: user.userRole,
        firstName: user.firstName,
        lastName: user.lastName,
        dataStatus: user.dataStatus,
        email: user.email,
    },
    "12345678",
    {
        expiresIn: "72h", // Set expiration to 72 hours
    }
);


}


module.exports={register,login,protectedRoute}