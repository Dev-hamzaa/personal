



const errorHandler=async(err,req,res,next)=>{
    try {


        console.log(err)
        next()
        
    } catch (error) {
        return next()
    }
}


module.exports={errorHandler}