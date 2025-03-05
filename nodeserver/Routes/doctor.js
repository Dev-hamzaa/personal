const express=require("express");

const { updateDoctor, doctorList,deleteDoctor,doctorDetail }=require("../controller/doctor/doctor");
const { userProtected } = require("../middleware/auth");
const docRouter = express.Router();

docRouter.route("/").get(doctorList);
docRouter
  .route("/:id")
  .get(doctorDetail)
  .put(updateDoctor)
  .delete(deleteDoctor);

module.exports= docRouter;
