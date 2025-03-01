const express=require("express")

const {patientList,updatePatient,deletePatient,getpatientDetail}=require("../controller/patient/patient");
const { userProtected } = require("../middleware/auth");
const patientRouter = express.Router();
patientRouter.route("/").get(patientList);
patientRouter
  .route("/:id")
  .get(getpatientDetail)
  .put(updatePatient)
  .delete(deletePatient);

module.exports=patientRouter;
