import Echo from "laravel-echo";
import Pusher from "pusher-js";

window.Pusher = Pusher;

function createEcho() {
  return new Echo({
    broadcaster: "reverb",
    key: "secret_key_123", // ⚠️ هذا يجب أن يكون REVERB_APP_KEY العام، لا أي سر حقيقي
    wsHost: "127.0.0.1",
    wsPort: 8080,
    wssPort: 8080,
    forceTLS: false,
    enabledTransports: ["ws", "wss"],

    // ضروري للقنوات الخاصة (private/presence channels) و notifications
    authEndpoint: "http://127.0.0.1:8000/broadcasting/auth",

    // مع Sanctum Bearer token: لا حاجة لـ CSRF ولا withCredentials
    authorizer: (channel) => ({
      authorize: (socketId, callback) => {
       const token = localStorage.getItem("token");
console.log("TOKEN:", token);
console.log(localStorage.getItem("token"));

console.log("TOKEN:", token);
console.log("CHANNEL:", channel.name);
console.log("SOCKET:", socketId);
        fetch("http://127.0.0.1:8000/broadcasting/auth", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
    Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          body: JSON.stringify({
            socket_id: socketId,
            channel_name: channel.name,
          }),
        })
          .then(async(res) => {
              console.log("STATUS:", res.status);
  console.log(await res.text());

            if (!res.ok) throw new Error(`فشل التوثيق: ${res.status}`);
            return res.json();
          })
          .then((data) => callback(false, data))
.catch(async (err) => {
    console.error("FULL ERROR:", err);
    callback(true, err);
});      },
    }),
  });
}

window.Echo = createEcho();

console.log("Echo تم إعداده يدوياً بدون env");