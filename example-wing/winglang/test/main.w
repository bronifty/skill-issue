bring cloud;
bring util;

let api = new cloud.Api();
let bucket = new cloud.Bucket();
bucket.addObject("filename.js", "./filename.js");
api.post("/upload", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
  // if let body = request.body {
    
  // }
  let fileContent = bucket.get("filename.js"); // get the binary content from the bucket

  return cloud.ApiResponse {
    status: 200,
    headers: { "Content-Type": "application/octet-stream" },
    body: fileContent
  };
});