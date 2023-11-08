// bring cloud;
// bring "./api.w" as wingpressoApi;
// let api = new wingpressoApi.Wingpresso("wingpresso_orders");


bring cloud;
bring http;
bring util;
bring "./storage.w" as storage;
// bring "./upload.w" as upload;
let api = new storage.Storage();

// let api = new cloud.Api({
//   cors: true,
//   corsOptions: {
//       allowHeaders: ["*"],
//       allowMethods: [http.HttpMethod.POST, http.HttpMethod.PUT, http.HttpMethod.GET, http.HttpMethod.DELETE],
//   },
// });
// let bucket = new cloud.Bucket();

// api.post("/upload", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
// log("in main.w api.post(/upload)");  
// if let fileContent = request.body {
//     // let encodedContent = util.base64Encode(fileContent); // encode the binary data to base64
//     // we need an extern function to extract the properties from fileContent; it is a json object
//     bucket.put("image.json", fileContent);
//     log("${fileContent}");
//     return cloud.ApiResponse {
//       status: 200,
//       body: "File uploaded successfully. ${fileContent}"
//     };
//   } else {
//     return cloud.ApiResponse {
//       status: 400,
//       body: "Missing file content."
//     };
//   }
// });

// api.post("/download", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
//   let filename = "image.json"; // replace with your logic to get the filename
//   let encodedJson = bucket.get(filename);
//   let parsedEncodedJson = Json.parse(encodedJson);
//   let fileData = parsedEncodedJson.tryGet("file");
//   let encodedContent = str.fromJson(fileData);

  
//   let optionalEncodedContent: str? = encodedContent;
  
//   if let fileContent = optionalEncodedContent {
//     let decodedContent = util.base64Decode(fileContent);
//     return cloud.ApiResponse {
//     status: 200,
//     headers: { "Content-Type": "application/octet-stream" },
//     body: decodedContent
//   };
//   } else {
//     return cloud.ApiResponse {
//       status: 404,
//       body: "File not found."
//     };
//   }
// });




let website = new cloud.Website(
  path: "../../vite/dist",
);
// website.addJson("config.json", { api: api.url });
// website.addJson("config.json", { api: api.ordersApi.url });
website.addJson("config.json", { api: api.storageApi.url });