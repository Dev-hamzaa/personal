import express from "express";
import mongoose from "mongoose";
import docRouter from "./Routes/doctor.js";
import { logger } from "./utils/logger.js";
import patientRouter from "./Routes/patient.js";
const app = express();

app.use(express.json());
app.use(logger);
const port = 5000;

const connectDB = async () => {
  await mongoose.connect("mongodb://localhost:27017/healthApp");
  console.log("MongoDB Connected!!");
};

connectDB();

app.use("/api/doctor", docRouter);
app.use("/api/patient", patientRouter);

app.listen(port, () => {
  console.log(`server is running on port ${port}`);
});
