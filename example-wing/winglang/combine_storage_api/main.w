bring cloud;
bring http;
bring util;
bring "./crud.w" as crud;
bring "./storage.w" as storage;
let api = new cloud.Api({
  cors: true,
  corsOptions: {
      allowHeaders: ["*"],
      allowMethods: [http.HttpMethod.POST, http.HttpMethod.PUT, http.HttpMethod.GET, http.HttpMethod.DELETE],
  },
});
let crudApi = new crud.Crud(api);
let storageApi = new storage.Storage(api);
let website = new cloud.Website(
  path: "../../vite/dist",
);
website.addJson("config.json", { api: api.url });
