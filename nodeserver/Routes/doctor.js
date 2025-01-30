import express from "express";
import {
  deleteDoctor,
  doctorDetail,
  doctorList,
  updateDoctor,
} from "../controller/doctor/doctor.js";

const docRouter = express.Router();

docRouter.route("/").get(doctorList);
docRouter
  .route("/:id")
  .get(doctorDetail)
  .put(updateDoctor)
  .delete(deleteDoctor);

export default docRouter;
