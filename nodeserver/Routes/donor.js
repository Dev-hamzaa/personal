const {
  getDonorDetail,
  updateDonor,
  deleteDonor,
  donorList,
} = require("../controller/Donor/donor");
const express = require("express");
const { userProtected } = require("../middleware/auth");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const { patchdoctor } = require("../controller/doctor/doctor");

const donorRouter = express.Router();

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

donorRouter.route("/").get(donorList);
donorRouter
  .route("/:id")
  .get(getDonorDetail)
  .put(upload.single("file"), updateDonor)
  .delete(deleteDonor);

module.exports = donorRouter;
