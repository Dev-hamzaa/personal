const User=require("../../model/user")


const createDoctor=async(req,reply)=>{
try {
  const {name,email,password,specialization}=req.body;
  const foundDoctor=await User.findOne(
    {
      email:email
    }
  )
  if(foundDoctor){
    return reply.json(
      
      {
        success:false,
        message:"Your email is already registered"
      }
    )
  }
  const newDoctor=await User.create(
    {
      name:name,
      password:password,
      email:email,
      specialization:specialization
    }
  )
  return reply.json(
    {
      success:true,
      message:"Doctor Signup successfully"
    }
  )
} catch (error) {
  return reply.json({
    message: "internal server Error",
    data: error.message,
  });
}
}



 const doctorList = async (req, reply) => {
  try {
    const { name } = req.query;
    let query = { userRole: "doctor" };
    if (name) {
      query = {
        ...query,
        name: {
          $regex: new RegExp(name, "i"),
        },
      };
    }
    const list = await User.find(query);
    return reply.json({
      success: true,
      message: "Doctors List",
      data: list,
    });
  } catch (error) {
    return reply.json({
      message: "internal server Error",
      data: error.message,
    });
  }
};

 const doctorDetail = async (req, reply) => {
  try {
    const { id } = req.params;
    const docDetail = await User.findById({
      _id: id,
    });

    if (!docDetail) {
      return reply.json({
        success: false,
        message: "doctor Not found",
      });
    }
    return reply.json({
      success: true,
      message: "Doctor Detail",
      data: docDetail,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

 const deleteDoctor = async (req, reply) => {
  try {
    const { id } = req.params;
    const delDoctor = await User.findByIdAndDelete({
      _id: id,
    });
    if (!delDoctor) {
      return reply.json({
        success: false,
        message: "Doctor not found",
      });
    }
    return reply.json({
      success: true,
      message: "Doctor Deleted",
      data: delDoctor,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

 const updateDoctor = async (req, reply) => {
  try {
    const { id } = req.params;
    const { name,email, specialization, phoneNumber,weeklySchedule } = req.body;

    const foundDoctor=await User.findById(
      {
        _id:id
      }
    )
    const updatedDoctor = await User.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        name,
        email:email,
        specialization,
        phoneNumber,
        weeklySchedule
      },
      {
        new: true,
      }
    );
    return reply.json({
      success: true,
      messsage: "Doctor updated ",
      data: updatedDoctor,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};
module.exports={updateDoctor,deleteDoctor,doctorDetail,doctorList}
