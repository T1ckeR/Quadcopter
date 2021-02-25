#include <SPI.h>
#include <WiFiNINA.h>

// recieving data order: throttle,yaw,pitch,roll

char* ssid = "UFO";
char* hostName = "UFO";
int network = WL_IDLE_STATUS;
String cmd;
String data;

String throttle;
String yaw;
String pitch;
String roll;

WiFiServer wifiServer(80);

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("Starting network...");
  WiFi.config(IPAddress(10, 0, 0, 1));
  WiFi.setHostname(hostName);
  network = WiFi.beginAP(ssid);
  if (network != WL_AP_LISTENING) {
    Serial.println("Failed to create network. Terminating process.");
    while (true);
  }
  delay(1000);
  printWiFiStatus();
  wifiServer.begin();
}

void loop() {
  WiFiClient client = wifiServer.available();
  //client.setTimeout(0);
  if (client) {
    while (client.connected()) {
      while (client.available()>0) {
        data = client.readStringUntil('/');
        Serial.println(data);
        if (data == "bye" or data == "hey") {
          if (data == "hey") {
            Serial.println("Client connected!");
          } else {
            client.stop();
            Serial.println("Client requested disconnect...");
          }
        } else {
          throttle = getValue(data, ',', 0);
          yaw = getValue(data, ',', 1);
          pitch = getValue(data, ',', 2);
          roll = getValue(data, ',', 3);
          Serial.println(throttle);
        }
      }
      delayMicroseconds(100);
    }
    client.stop();
    Serial.println("Client has been disconnected!");
  }
  delay(10);
}

 String getValue(String data, char separator, int index)
{
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length()-1;

  for(int i=0; i<=maxIndex && found<=index; i++){
    if(data.charAt(i)==separator || i==maxIndex){
        found++;
        strIndex[0] = strIndex[1]+1;
        strIndex[1] = (i == maxIndex) ? i+1 : i;
    }
  }

  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}

void printWiFiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
}
