const express = require("express");

const { userProtected } = require("../middleware/auth");
const appointRouter = express.Router();
const {
  createAppointment,
  getAppointments,
  getAppointmentDetail,
  updateAppoitment,
  delAppointment,
} = require("../controller/appointment/appointment");

appointRouter.route("/").post(createAppointment);
appointRouter.route("/").get(getAppointments);
appointRouter
  .route("/:id")
  .get(getAppointmentDetail)
  .put(updateAppoitment)
  .delete(delAppointment);

module.exports = appointRouter;
