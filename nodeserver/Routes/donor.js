const {getDonorDetail,updateDonor,deleteDonor,donorList}=require("../controller/Donor/donor")
const express=require("express")


const donorRouter = express.Router();

donorRouter.route("/").get(donorList);
donorRouter
  .route("/:id")
  .get(getDonorDetail)
  .put(updateDonor)
  .delete(deleteDonor);

module.exports=donorRouter