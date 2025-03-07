const mongoose = require("mongoose");

const donorRequestSchema = new mongoose.Schema(
  {
    patientId: {
      type: mongoose.Schema.Types.ObjectId, // ✅ Fix: Directly use ObjectId
      ref: "User",
    },
    donorId: {
      type: mongoose.Schema.Types.ObjectId, // ✅ Fix: Directly use ObjectId
      ref: "User",
    },
    // appointmentDate: {
    //   type: Date,
    // },
    requestedOrgan: {
      type: String,
    },
    status: {
      type: String,
      // enum: ["complete", "cancel", "pending"],
      default: "pending",
    },
  },
  {
    timestamps: true,
  }
);

const donorRequest = mongoose.model("DonorRequest", donorRequestSchema);
module.exports = { donorRequest };
