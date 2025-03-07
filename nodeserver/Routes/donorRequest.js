const express = require("express");

const { userProtected } = require("../middleware/auth");
const {
  createRequest,
  getRequests,
  getRequestDetail,
  updateRequest,
  delRequest,
  getPatientRequest,
} = require("../controller/Donor/donorRequest");
const requestRouter = express.Router();

requestRouter.route("/").post(createRequest);
requestRouter.route("/").get(getRequests);
requestRouter.route("/patient").get(getPatientRequest);

requestRouter
  .route("/:id")
  .get(getRequestDetail)
  .patch(updateRequest)
  .delete(delRequest);

module.exports = requestRouter;
