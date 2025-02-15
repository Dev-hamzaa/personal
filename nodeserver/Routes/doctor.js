import express from "express";
import {
  createDoctor,
  deleteDoctor,
  doctorDetail,
  doctorList,
  updateDoctor,
} from "../controller/doctor/doctor.js";

const docRouter = express.Router();

docRouter.route('/').post(createDoctor)
docRouter.route("/").get(doctorList);
docRouter
  .route("/:id")
  .get(doctorDetail)
  .put(updateDoctor)
  .delete(deleteDoctor);

export default docRouter;
