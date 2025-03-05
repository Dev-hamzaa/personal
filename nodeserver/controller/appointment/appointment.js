const createAppointment=async(req,res,next)=>{
try {
    
} catch (error) {
    return res.json({
        success: false,
        message: "Internal server error",
        error: error.message,
      });
}
}