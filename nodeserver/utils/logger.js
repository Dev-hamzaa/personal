export const logger = async (req, reply) => {
  console.log(`${req.method}\t${req.url}\t${req.headers.origin}`);
};
