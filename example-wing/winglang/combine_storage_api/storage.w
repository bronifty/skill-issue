bring cloud;
bring ex;
bring util;
bring http;

class Storage {
  pub api: cloud.Api;
  pub bucket: cloud.Bucket;

  init(cloudApi: cloud.Api){
    this.api = cloudApi;
    this.bucket = new cloud.Bucket(
      public: true,
    );
    this.setup();
  }

  extern "../../lib/utils.cjs" pub static inflight parseInputFile(inputFile: str): Json;
  extern "../../lib/utils.cjs" pub static inflight returnHelloWorld(): str;
  extern "../../lib/utils.cjs" pub static inflight transformJsonFileToBinary(inputJson: Json): Json;
  extern "../../lib/utils.cjs" pub static inflight prepareBase64File(inputJson: Json): str;

  pub setPostUploadHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
      if let body = request.body {
        let jsonData = Json.parse(body); 
        let file = jsonData.tryGet("file");
        let fileNameJson = jsonData.tryGet("fileName");
        let fileNameStr = str.fromJson(fileNameJson);
        let fileName = fileNameStr + ".json";
        log("fileName ${fileName}");
        log("in postUploadHandler fileName ${fileName}");
        try {
          this.bucket.put("${fileName}", body);
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
        let jsonData = Json.parse(body); 
        let fileName = jsonData.tryGet("fileName");
        log("fileName ${fileName}");
        log("in postDownloadHandler fileName ${fileName}");
        try {
        let encodedJson = this.bucket.get("${fileName}.json");
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
    this.api.post("/upload", this.setPostUploadHandler());  
    this.api.post("/download", this.setPostDownloadHandler());  
  }
}
