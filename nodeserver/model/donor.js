import mongoose from "mongoose";
const donorSchema = new mongoose.Schema(
  {
    name: { type: String },
    fcmApp: { type: String },
    gender: { type: String, enum: ["male", "female"] },
    emergencyNumber: { type: String },
    profilePic: { type: String },
    bloodType: { type: String },
    selectedOrgan:{type:String},
    phoneNumber: { type: String },
    userRole: {
      type: String,
      enum: ["admin", "patient", "donor", "doctor"],
      default: "donor",
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
  },
  {
    timestamps: true,
  }
);

export const Donor = mongoose.model("Donor", donorSchema);
