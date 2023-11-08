bring "./javascript.w" as javascript;

log("javascript.Store.isValidUrl('http://www.google.com') ${javascript.Store.isValidUrl("http://www.google.com")}");
log("!Store.isValidUrl('X?Y') ${!javascript.Store.isValidUrl("X?Y")}");

assert(javascript.Store.isValidUrl("http://www.google.com"));
assert(!javascript.Store.isValidUrl("X?Y"));
