bring cloud;
bring ex;
bring util;
bring http;

struct Order {
  productId: str;
  customerId: str;
  status: str?;
}

class Crud {
  pub api: cloud.Api;
  pub ordersCounter: cloud.Counter;
  pub ordersTopic: cloud.Topic;
  pub table: ex.Table;

  init(cloudApi: cloud.Api){
    this.api = cloudApi;
    this.ordersCounter = new cloud.Counter(initial: 0);
    this.ordersTopic = new cloud.Topic();
    this.table = new ex.Table(
      name: "orders",
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
          this.table.insert(id, orderData);  
          this.ordersTopic.publish("order id: ${id} customer ${orderData.customerId} purchased ${orderData.productId}");
        } catch e {
          throw("db insert exception");
          log("${e} db insert exception");
        } finally {
          log("done");
          return cloud.ApiResponse {
            status: 201,
            body: "${id}, customer ${orderData.customerId} purchased ${orderData.productId}"
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
        let orderTableData = this.table.get(request.vars.get("id")); // {id: 0, productId: "coffee", customerId: "john", status: nil}
          let orderDataJson = Json {
            productId: orderTableData.get("productId"),
            customerId: orderTableData.get("customerId"),
            status: jsonStatus
          };  
          let orderDataStruct = this.toOrderFromJson(orderDataJson); 
        try {
          this.table.update(request.vars.get("id"), orderDataJson);
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
      let requestData = this.table.get(request.vars.get("id"));
      // log(str.fromJson(requestData));
      let orderData = this.toOrderFromJson(requestData);
      return cloud.ApiResponse {
        status: 200,
        body: Json.stringify("customer: ${orderData.customerId}")
      };
    };
  }
  
  setup() {
    this.ordersTopic.onMessage(this.setLogMessage());
    this.api.post("/order", this.setPostOrderHandler());  
    this.api.put("/order/{id}", this.setPutOrderHandler());  
    this.api.get("/order/{id}", this.setGetOrderHandler());  
  }
}