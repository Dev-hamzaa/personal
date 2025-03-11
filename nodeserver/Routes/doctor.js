const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const {
  updateDoctor,
  doctorList,
  deleteDoctor,
  doctorDetail,
  patchdoctor,
} = require("../controller/doctor/doctor");
const { userProtected } = require("../middleware/auth");
const docRouter = express.Router();

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

docRouter.route("/").get(doctorList);
docRouter
  .route("/:id")
  .get(doctorDetail)
  .put(upload.single("file"), updateDoctor)
  .delete(deleteDoctor);

docRouter.route("/patch/:id").patch(patchdoctor);

module.exports = docRouter;
