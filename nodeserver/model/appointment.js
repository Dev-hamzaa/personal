const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema(
  {
    patientId: {
      type: mongoose.Schema.Types.ObjectId, // ✅ Fix: Directly use ObjectId
      ref: "User",
    },
    doctorId: {
      type: mongoose.Schema.Types.ObjectId, // ✅ Fix: Directly use ObjectId
      ref: "User",
    },
    appointmentDate: {
      type: Date,
    },
    time: {
      type: String,
    },
    status: {
      type: String,
      enum: ["complete", "cancel", "pending"],
      default: "pending",
    },
  },
  {
    timestamps: true,
  }
);

const Appointment = mongoose.model("Appointment", appointmentSchema);
module.exports = { Appointment };
