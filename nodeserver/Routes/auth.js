
const express =require("express");
const { register, login,protectedRoute } = require("../controller/authentication/auth");
const { userProtected } = require("../middleware/auth");



const authRouter = express.Router();


authRouter.route("/register").post(register);

authRouter.route("/login").post(login);
authRouter.route("/protect").get(userProtected,protectedRoute)

module.exports=authRouter
