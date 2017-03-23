var Scribe = require('scribe').Scribe;
var scribe = new Scribe('localhost', 1463, {"autoReconnect": true});
scribe.open();
function send_test() {
  scribe.send("test-host.local", "test message" + (new Date().getTime()/1000|0));
  setTimeout(send_test, 1000);
}
setTimeout(send_test, 1000);
