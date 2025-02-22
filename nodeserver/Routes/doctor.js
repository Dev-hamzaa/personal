const express=require("express");

const { updateDoctor, doctorList,deleteDoctor,doctorDetail }=require("../controller/doctor/doctor")
const docRouter = express.Router();

docRouter.route("/").get(doctorList);
docRouter
  .route("/:id")
  .get(doctorDetail)
  .put(updateDoctor)
  .delete(deleteDoctor);

module.exports= docRouter;
