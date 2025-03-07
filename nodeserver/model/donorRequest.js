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
    bloodType: {
      type: String,
    },
    requestedOrgan: {
      type: String,
    },
    status: {
      type: String,
      // enum: ["complete", "cancel", "pending"],
      default: "pending",
    },
    bloodOnly: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

const donorRequest = mongoose.model("DonorRequest", donorRequestSchema);
module.exports = { donorRequest };
