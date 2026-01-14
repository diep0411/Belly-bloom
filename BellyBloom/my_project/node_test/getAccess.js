import { GoogleAuth } from "google-auth-library";

const auth = new GoogleAuth({
  keyFile: "babyapp-bade7-c42c711013d6.json",
  scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
});

const accessToken = await auth.getAccessToken();
console.log("Access Token:", accessToken);
