bring cloud;
bring http;
// bring "./api.w" as wingpressoApi;
// let api = new wingpressoApi.Wingpresso("wingpresso_orders");

let api = new cloud.Api({
  cors: true,
  corsOptions: {
      allowHeaders: ["*"],
      allowMethods: [http.HttpMethod.POST, http.HttpMethod.PUT, http.HttpMethod.GET, http.HttpMethod.DELETE],
  },
});

// handle all requests
api.post("*", inflight () => {});  
api.get("*", inflight () => {});  

let website = new cloud.Website(
  path: "../../vite/dist",
);
website.addJson("config.json", { api: api.url });