const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");

const {
  patientList,
  updatePatient,
  deletePatient,
  getpatientDetail,
} = require("../controller/patient/patient");
const { userProtected } = require("../middleware/auth");
const patientRouter = express.Router();

const uploadsDir = path.join(__dirname, "../uploads");

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir);
}
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  },
});

const upload = multer({ storage: storage });

patientRouter.route("/").get(patientList);
patientRouter
  .route("/:id")
  .get(getpatientDetail)
  .put(upload.single("file"), updatePatient)
  .delete(deletePatient);

module.exports = patientRouter;
