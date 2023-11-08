bring cloud;
bring ex;
bring util;
bring http;

class Storage {
  pub storageApi: cloud.Api;
  pub s3Bucket: cloud.Bucket;

  init(){
    this.s3Bucket = new cloud.Bucket(
      public: true,
    );
    this.storageApi = new cloud.Api({
      cors: true,
      corsOptions: {
          allowHeaders: ["*"],
          allowMethods: [http.HttpMethod.POST, http.HttpMethod.PUT, http.HttpMethod.GET, http.HttpMethod.DELETE],
      },
    });
    this.setup();
  }

  extern "../../lib/utils.cjs" pub static inflight parseInputFile(inputFile: str): Json;
  extern "../../lib/utils.cjs" pub static inflight returnHelloWorld(): str;
  extern "../../lib/utils.cjs" pub static inflight transformJsonFileToBinary(inputJson: Json): Json;
  extern "../../lib/utils.cjs" pub static inflight prepareBase64File(inputJson: Json): str;

  pub setPostUploadHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
      if let body = request.body {
        // let jsonData = Storage.parseInputFile(body);
        // log(Storage.returnHelloWorld());
        
        let jsonData = Json.parse(body); 
        let file = jsonData.tryGet("file");
        let fileNameJson = jsonData.tryGet("fileName");
        let fileNameStr = str.fromJson(fileNameJson);
        let fileName = fileNameStr + ".json";
        log("fileName ${fileName}");
        log("in postUploadHandler fileName ${fileName}");
        try {
          this.s3Bucket.put("${fileName}", body);
          // this.s3Bucket.put(str.fromJson(fileName), body);
        } catch e {
          log("${e} error");
        }
      return cloud.ApiResponse {
        status: 200,
        body: Json.stringify("fileName: ${fileName}")
      };
      }
    };
  }
  pub setPostDownloadHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
      if let body = request.body {
        // let jsonData = Storage.parseInputFile(body);
        // log(Storage.returnHelloWorld());
        
        let jsonData = Json.parse(body); 
        let fileName = jsonData.tryGet("fileName");
        log("fileName ${fileName}");
        log("in postDownloadHandler fileName ${fileName}");
        try {
        let encodedJson = this.s3Bucket.get("${fileName}.json");

        // let encodedJson = bucket.get(filename);
          // let parsedEncodedJson = Json.parse(encodedJson);
          // let preparedEncodedFile = Storage.prepareBase64File(parsedEncodedJson); 
          // let decodedContent = util.base64Decode(preparedEncodedFile);

      
        
          return cloud.ApiResponse {
              status: 200,
              headers: { "Content-Type": "application/json" },
              body: encodedJson
        };
        } catch e {
          log("${e} error");
          return cloud.ApiResponse {
              status: 500,
              headers: { "Content-Type": "application/octet-stream" },
              body: Json.stringify(e)
        };
        }
        
      }
    };
  }

  setup() {
    this.storageApi.post("/upload", this.setPostUploadHandler());  
    this.storageApi.post("/download", this.setPostDownloadHandler());  
  }
}


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