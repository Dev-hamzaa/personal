const express=require("express");
const {logger} = require("./utils/logger");
const authRouter=require('./Routes/auth');
const doctorRouter=require("./Routes/doctor")
const connectDb = require("./config/db");
const donorRouter = require("./Routes/donor");
const patientRouter = require("./Routes/patient");
const cors=require("cors")

const app = express();

app.use(cors())
app.use(express.json());
app.use(logger);
const port = 4000;

connectDb().then(
  ()=>{
    console.log("Mongodb Connected");
    
  }
)
app.get("/api", (req, res) => {
    console.log("here")
    res.json({ message: "Auth route working!" });
  });

app.use("/api/auth",authRouter)
app.use("/api/doctor",doctorRouter) 
app.use("/api/donor",donorRouter) 
 
app.use("/api/patient",patientRouter) 
  app.listen(port, () => {
    console.log(`server is running on port ${port}`);
  });
  