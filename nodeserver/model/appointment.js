import mongoose from "mongoose";

const appointmentSchema = new mongoose.Schema(
  {
    patientId: {
      type: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    },
    doctorId: {
      type: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    },
    appointmentDate: {
      type: mongoose.Schema.type.Date,
    },
    status: {
      type: String,
      enum: ["complete", "cancel", "pending"],
    },
  },
  {
    timestamps: true,
  }
);

export const Appointment = mongoose.model("Appointment", appointmentSchema);
