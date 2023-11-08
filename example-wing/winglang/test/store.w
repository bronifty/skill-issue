bring cloud;

class Store {
  pub data: cloud.Bucket;
  init() {
    this.data = new cloud.Bucket(public: true);
  }
  extern "filename.js" pub static functionName(signature: str): bool;
}