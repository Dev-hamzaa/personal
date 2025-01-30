import express from "express";

import {
  deletePatient,
  getpatientDetail,
  patientList,
  updatePatient,
} from "../controller/patient/patient.js";

const patientRouter = express.Router();

patientRouter.route("/").get(patientList);
patientRouter
  .route("/:id")
  .get(getpatientDetail)
  .put(updatePatient)
  .delete(deletePatient);

export default patientRouter;
