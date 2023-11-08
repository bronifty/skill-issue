bring cloud;
bring ex;
bring util;
bring http;

// let api = new cloud.Api({
//     cors: true,
//     corsOptions: {
//         allowHeaders: ["*"],
//         allowMethods: [http.HttpMethod.POST, http.HttpMethod.GET],
//     },
// });

struct Order {
  productId: str;
  customerId: str;
  status: str?;
}

class Wingpresso {
  pub ordersApi: cloud.Api;
  pub ordersCounter: cloud.Counter;
  pub ordersTopic: cloud.Topic;
  pub ordersTable: ex.Table;
  pub s3Bucket: cloud.Bucket;

  init(tableName: str){
    this.s3Bucket = new cloud.Bucket(
      public: true,
    );
    this.ordersApi = new cloud.Api({
      cors: true,
      corsOptions: {
          allowHeaders: ["*"],
          allowMethods: [http.HttpMethod.POST, http.HttpMethod.PUT, http.HttpMethod.GET, http.HttpMethod.DELETE],
      },
    });
    this.ordersCounter = new cloud.Counter(initial: 0);
    this.ordersTopic = new cloud.Topic();
    this.ordersTable = new ex.Table(
      name: tableName,
      primaryKey: "id",
      columns: {
        "productId" => ex.ColumnType.STRING,
        "customerId" => ex.ColumnType.STRING,
        "status" => ex.ColumnType.STRING
      }
    ) as "Wingpresso-Orders";
    this.setup();
  }

  pub inflight toOrderFromJson(jsonData: Json): Order {
    try {
      let productId = str.fromJson(jsonData.tryGet("productId"));
      let customerId = str.fromJson(jsonData.tryGet("customerId"));
      return Order {
        productId: productId,
        customerId: customerId,
        status: "pending"
      };
    } catch err {
      log("Error during conversion to Json: ${err}");
    } finally { 
      log("converted to Order struct from Json");
    }
  }

  pub setLogMessage(): inflight (str): void {
    return inflight (msg: str): void => {
      log("${msg}!");
    };
  }

  pub setPostOrderHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
      if let body = request.body {
        let jsonData = Json.parse(body);
        let id = "${this.ordersCounter.inc()}";
        let orderData = this.toOrderFromJson(jsonData);
        try {
          this.ordersTable.insert(id, orderData);  
          this.ordersTopic.publish("order id: ${id} customer ${orderData.customerId} purchased ${orderData.customerId}");
        } catch e {
          throw("db insert exception");
          log("${e} db insert exception");
        } finally {
          log("done");
          return cloud.ApiResponse {
            status: 201,
            body: "${id}, customer ${orderData.customerId} purchased ${orderData.customerId}"
          };
        } 
      }
    };
  }

  pub setPutOrderHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
      if let body = request.body {
        let jsonBody = Json.parse(body); 
        let jsonStatus = jsonBody.tryGet("status"); 
        let orderTableData = this.ordersTable.get(request.vars.get("id")); // {id: 0, productId: "coffee", customerId: "john", status: nil}
          let orderDataJson = Json {
            productId: orderTableData.get("productId"),
            customerId: orderTableData.get("customerId"),
            status: jsonStatus
          };  
          let orderDataStruct = this.toOrderFromJson(orderDataJson); 
        try {
          this.ordersTable.update(request.vars.get("id"), orderDataJson);
          this.ordersTopic.publish("order id: ${request.vars.get("id")} customer ${orderDataStruct.customerId} order ${orderDataStruct.productId} status updated to ${orderDataStruct.status}");
        } catch e {
          throw("db insert exception");
          log("${e} db insert exception");
        } finally {
          log("done");
          return cloud.ApiResponse {
            status: 201,
            body: "order id: ${request.vars.get("id")} customer ${orderDataStruct.customerId} order ${orderDataStruct.productId} status updated to ${orderDataStruct.status}"
          };
        } 
       }
    };
  }

  pub setGetOrderHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
      let requestData = this.ordersTable.get(request.vars.get("id"));
      // log(str.fromJson(requestData));
      let orderData = this.toOrderFromJson(requestData);
      return cloud.ApiResponse {
        status: 200,
        body: Json.stringify("customer: ${orderData.customerId}")
      };
    };
  }
  pub setPostUploadHandler(): inflight (cloud.ApiRequest): cloud.ApiResponse {
    return inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
 
    if let body = request.body {
        let jsonBody = Json.parse(body); 
        let file = jsonBody.tryGet("file");
        log("${jsonBody}");
        try {
          this.s3Bucket.put("file.txt", "Hello, world!");
        } catch e {
          log("${e} error");
        }
    
      return cloud.ApiResponse {
        status: 200,
        body: Json.stringify("customer: ${file}")
      };
      }
    };
  }

  

  setup() {
    this.ordersTopic.onMessage(this.setLogMessage());
    this.ordersApi.post("/orders", this.setPostOrderHandler());  
    this.ordersApi.put("/orders/{id}", this.setPutOrderHandler());  
    this.ordersApi.get("/orders/{id}", this.setGetOrderHandler());  
    this.ordersApi.post("/uploads", this.setPostUploadHandler());  
  }
}