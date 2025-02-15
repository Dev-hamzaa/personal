import { Patient } from "../../model/patient.js";




export const createPatient=async(req,reply)=>{
try {
  const {name,email,password}=req.body;
  const foundPatient=await Patient.findOne(
    {
      email:email
    }
  )
  if(foundPatient){
    return reply.json(
      
      {
        success:false,
        message:"Your email is already registered"
      }
    )
  }
  const newPatient=await Patient.create(
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
      message:"Patient Signup successfully"
    }
  )
} catch (error) {
  return reply.json({
    message: "internal server Error",
    data: error.message,
  });
}
}



export const patientList = async (req, reply) => {
  try {
    const { name } = req.query;
    // let query = { userRole: "patient" };
    if (name) {
      query = {
        ...query,
        name: {
          $regex: new RegExp(name, "i"),
        },
      };
    }
    const list = await Patient.find(query);
    return reply.json({
      success: true,
      message: "Patients List",
      data: list,
    });
  } catch (error) {
    return reply.json({
      message: "internal server Error",
      data: error.message,
    });
  }
};

export const getpatientDetail = async (req, reply) => {
  try {
    const { id } = req.params;
    const patientDetail = await Patient.findById({
      _id: id,
    });

    if (!patientDetail) {
      return reply.json({
        success: false,
        message: "patient Not found",
      });
    }
    return reply.json({
      success: true,
      message: "patient Detail",
      data: patientDetail,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

export const deletePatient = async (req, reply) => {
  try {
    const { id } = req.params;
    const delPatient = await Patient.findByIdAndDelete({
      _id: id,
    });
    if (!delPatient) {
      return reply.json({
        success: false,
        message: "Patient not found",
      });
    }
    return reply.json({
      success: true,
      message: "Patient Deleted",
      data: delPatient,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};

export const updatePatient = async (req, reply) => {
  try {
    const { id } = req.params;
    const { firstName, lastName, emergencyNumber, phoneNumber } = req.body;
    const updatePatient = await Patient.findByIdAndUpdate(
      {
        _id: id,
      },
      {
        firstName,
        lastName,
        emergencyNumber,
        phoneNumber,
      },
      {
        new: true,
      }
    );
    return reply.json({
      success: true,
      messsage: "patient updated ",
      data: updatePatient,
    });
  } catch (error) {
    return reply.json({
      message: "internal server error",
      data: error.message,
    });
  }
};
