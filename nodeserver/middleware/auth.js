const User = require("../model/user");
const ErrorResponse = require("../utils/error");

const userProtected = async (req, res, next) => {
    let token;
    if (
      req.headers.authorization &&
      req.headers.authorization.startsWith("Bearer")
    ) {
      token = req.headers.authorization.split(" ")[1];
    }
    if (!token) {
      return next(new ErrorResponse("Not authorized to access this route", 401));
    }
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);
      const user = await User.findById(decoded.id);
  
      if (!user) {
        return next(new ErrorResponse("No user found", 404));
      }
      if (user.dataStatus === "block") {
        return next(new ErrorResponse("User is blocked", 401));
      }
      req.user = user;
      next();
    } catch (err) {
      if (err.name === "TokenExpiredError") {
        return next(new ErrorResponse("Token has expired", 401));
      }
      return next(
        new ErrorResponse(`Not authorized to access this router.`, 401),
      );
    }
  };


  module.exports={userProtected}