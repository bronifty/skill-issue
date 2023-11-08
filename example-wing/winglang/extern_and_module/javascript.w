bring cloud;

class Store{
  bucket: cloud.Bucket;
  init() {
    this.bucket = new cloud.Bucket();
  }
  extern "./javascript.js" pub static isValidUrl(url: str): bool;
}
