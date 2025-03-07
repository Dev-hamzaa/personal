const mongoose = require("mongoose");
const userSchema = new mongoose.Schema(
  {
    name: { type: String },
    fcmApp: { type: String },
    gender: { type: String, enum: ["male", "female"] },
    phone: { type: String },
    profilePic: { type: String },
    bloodType: { type: String },
    specialization: { type: String },
    selectedOrgan: { type: [String] },
    // phoneNumber: { type: String },
    userRole: {
      type: String,
      enum: ["admin", "patient", "donor", "doctor"],
      default: "admin",
    },
    email: {
      type: String,
      required: [true, "Please provide email address"],
      unique: true,
      match: [
        /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
        "Please provide a valid email",
      ],
    },
    password: {
      type: String,

      minlength: 6,
      select: false,
    },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    modifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    weeklySchedule: [
      {
        _id: false,
        day: String,
        start: mongoose.Schema.Types.Date,
        end: mongoose.Schema.Types.Date,
      },
    ],
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model("User", userSchema);
module.exports = User;
