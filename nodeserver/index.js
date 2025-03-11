const express = require("express");
const { logger } = require("./utils/logger");
const authRouter = require("./Routes/auth");
const doctorRouter = require("./Routes/doctor");
const connectDb = require("./config/db");
const donorRouter = require("./Routes/donor");
const patientRouter = require("./Routes/patient");
const appointRouter = require("./Routes/appointment");
const requestRouter = require("./Routes/donorRequest");
const cors = require("cors");
const { errorHandler } = require("./controller/authentication/error");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());
app.use(logger);
app.use((req, res, next) => {
  console.log(`Static File Request: ${req.url}`);
  next();
});
// Serve static files from the uploads directory
app.use("/uploads", express.static(path.join(__dirname, "./uploads")));
const port = 8000;

connectDb().then(() => {
  console.log("Mongodb Connected");
});
app.get("/api", (req, res) => {
  console.log("here");
  res.json({ message: "Auth route working!" });
});

app.use("/api/auth", authRouter);
app.use("/api/doctor", doctorRouter);
app.use("/api/donor", donorRouter);
app.use("/api/appoint", appointRouter);
app.use("/api/request", requestRouter);

app.use(errorHandler);

app.use("/api/patient", patientRouter);
app.listen(port, () => {
  console.log(`server is running on port ${port}`);
});
