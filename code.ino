#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <DHT.h>

// =====================================================
// WIFI
// =====================================================

const char* ssid = "biznet.id";
const char* password = "123123123";


// =====================================================
// PIN
// =====================================================

#define DHTPIN 4
#define DHTTYPE DHT11

// RELAY
#define RELAY_PUMP_PIN 26        // Relay 1 - Pompa Air
#define RELAY_PESTICIDE_PIN 27   // Relay 2 - Pompa Pestisida

#define TRIG_PIN 5
#define ECHO_PIN 18

#define SOIL_PIN 34


// =====================================================
// OBJECT
// =====================================================

DHT dht(DHTPIN, DHTTYPE);

WebServer server(80);


// =====================================================
// SENSOR STATUS
// =====================================================

// Pompa Air
bool pumpState = false;

// Pompa Pestisida
bool pesticideState = false;

float temperature = 0;
float humidity = 0;
float distance = 0;

int soilRaw = 0;
int soilPercent = 0;


// =====================================================
// TIMER
// =====================================================

unsigned long lastSensorRead = 0;

const unsigned long SENSOR_INTERVAL = 3000;

// =====================================================
// TELEMETRY KE LARAVEL
// =====================================================

const char* laravelUrl = "http://192.168.43.182:8000/api/telemetry";

unsigned long lastTelemetryPost = 0;

const unsigned long TELEMETRY_INTERVAL = 5000;


// =====================================================
// RELAY - POMPA AIR
// =====================================================

// Relay ACTIVE HIGH
// HIGH = ON
// LOW  = OFF

void pumpON() {

  digitalWrite(RELAY_PUMP_PIN, HIGH);

  pumpState = true;

  Serial.println();
  Serial.println(">>> POMPA AIR ON");
}


void pumpOFF() {

  digitalWrite(RELAY_PUMP_PIN, LOW);

  pumpState = false;

  Serial.println();
  Serial.println(">>> POMPA AIR OFF");
}


// =====================================================
// RELAY - POMPA PESTISIDA
// =====================================================

// Relay ACTIVE HIGH
// HIGH = ON
// LOW  = OFF

void pesticideON() {

  digitalWrite(RELAY_PESTICIDE_PIN, HIGH);

  pesticideState = true;

  Serial.println();
  Serial.println(">>> POMPA PESTISIDA ON");
}


void pesticideOFF() {

  digitalWrite(RELAY_PESTICIDE_PIN, LOW);

  pesticideState = false;

  Serial.println();
  Serial.println(">>> POMPA PESTISIDA OFF");
}


// =====================================================
// BACA ULTRASONIC
// =====================================================

float readDistance() {

  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);

  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(
    ECHO_PIN,
    HIGH,
    30000
  );

  if (duration == 0) {

    return 0;
  }

  float distanceCm =
    duration * 0.0343 / 2.0;

  return distanceCm;
}


// =====================================================
// BACA SEMUA SENSOR
// =====================================================

void readSensors() {

  // ===================================================
  // DHT11
  // ===================================================

  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (!isnan(temp)) {

    temperature = temp;
  }

  if (!isnan(hum)) {

    humidity = hum;
  }


  // ===================================================
  // ULTRASONIC
  // ===================================================

  distance = readDistance();


  // ===================================================
  // SOIL SENSOR
  // ===================================================

  soilRaw = analogRead(SOIL_PIN);

  soilPercent = map(
    soilRaw,
    3200,
    1500,
    0,
    100
  );

  soilPercent = constrain(
    soilPercent,
    0,
    100
  );


  // ===================================================
  // SERIAL MONITOR
  // ===================================================

  Serial.println();
  Serial.println("========================================");
  Serial.println("             SENSOR UPDATE");
  Serial.println("========================================");

  Serial.print("Temperature       : ");
  Serial.print(temperature, 1);
  Serial.println(" C");

  Serial.print("Humidity          : ");
  Serial.print(humidity, 0);
  Serial.println(" %");

  Serial.print("Distance          : ");
  Serial.print(distance, 1);
  Serial.println(" cm");

  Serial.print("Soil RAW          : ");
  Serial.println(soilRaw);

  Serial.print("Soil              : ");
  Serial.print(soilPercent);
  Serial.println(" %");

  Serial.print("Pompa Air         : ");

  if (pumpState) {
    Serial.println("ON");
  } else {
    Serial.println("OFF");
  }

  Serial.print("Pompa Pestisida   : ");

  if (pesticideState) {
    Serial.println("ON");
  } else {
    Serial.println("OFF");
  }

  Serial.println("========================================");
}


// =====================================================
// POST TELEMETRY KE LARAVEL
// =====================================================

void postTelemetry() {

  if (WiFi.status() != WL_CONNECTED) {
    return;
  }

  String json = "{";

  json += "\"node\":\"ESP32 Node 2\"";
  json += ",";

  json += "\"temp\":";
  json += String(temperature, 1);
  json += ",";

  json += "\"humidity\":";
  json += String(humidity, 0);
  json += ",";

  json += "\"dist\":";
  json += String(distance, 1);
  json += ",";

  json += "\"soil\":";
  json += String(soilPercent);
  json += ",";

  json += "\"pumpStatus\":";
  json += pumpState ? "\"Aktif\"" : "\"Standby\"";

  json += "}";

  HTTPClient http;
  http.begin(laravelUrl);
  http.addHeader("Content-Type", "application/json");

  int code = http.POST(json);

  if (code > 0) {
    Serial.println();
    Serial.print("[LARAVEL] Telemetry terkirim: ");
    Serial.println(code);
  } else {
    Serial.println();
    Serial.println("[LARAVEL] Gagal kirim telemetry");
  }

  http.end();
}


// =====================================================
// HTTP GET /
// =====================================================

void handleRoot() {

  String message;

  message += "ESP32 SMART FARM";
  message += "\n";
  message += "==============================";
  message += "\n";
  message += "ESP32 ONLINE";
  message += "\n\n";

  message += "Endpoints:";
  message += "\n";

  message += "GET /status";
  message += "\n";

  message += "GET /pump/on";
  message += "\n";

  message += "GET /pump/off";
  message += "\n";

  message += "GET /pesticide/on";
  message += "\n";

  message += "GET /pesticide/off";
  message += "\n";

  server.send(
    200,
    "text/plain",
    message
  );
}


// =====================================================
// HTTP GET /status
// =====================================================

void handleStatus() {

  String json = "{";

  json += "\"temperature\":";
  json += String(temperature, 1);
  json += ",";

  json += "\"humidity\":";
  json += String(humidity, 0);
  json += ",";

  json += "\"distance\":";
  json += String(distance, 1);
  json += ",";

  json += "\"soilRaw\":";
  json += String(soilRaw);
  json += ",";

  json += "\"soil\":";
  json += String(soilPercent);
  json += ",";

  // STATUS POMPA AIR
  json += "\"pump\":";
  json += pumpState ? "true" : "false";
  json += ",";

  // STATUS POMPA PESTISIDA
  json += "\"pesticide\":";
  json += pesticideState ? "true" : "false";

  json += "}";

  server.send(
    200,
    "application/json",
    json
  );
}


// =====================================================
// HTTP GET /pump/on
// =====================================================

void handlePumpOn() {

  pumpON();

  server.send(
    200,
    "application/json",
    "{\"success\":true,\"pump\":true}"
  );
}


// =====================================================
// HTTP GET /pump/off
// =====================================================

void handlePumpOff() {

  pumpOFF();

  server.send(
    200,
    "application/json",
    "{\"success\":true,\"pump\":false}"
  );
}


// =====================================================
// HTTP GET /pesticide/on
// =====================================================

void handlePesticideOn() {

  pesticideON();

  server.send(
    200,
    "application/json",
    "{\"success\":true,\"pesticide\":true}"
  );
}


// =====================================================
// HTTP GET /pesticide/off
// =====================================================

void handlePesticideOff() {

  pesticideOFF();

  server.send(
    200,
    "application/json",
    "{\"success\":true,\"pesticide\":false}"
  );
}


// =====================================================
// WIFI CONNECTION
// =====================================================

bool connectWiFi() {

  Serial.println();
  Serial.println("========================================");
  Serial.println("             WIFI CONNECTION");
  Serial.println("========================================");

  Serial.print("SSID     : ");
  Serial.println(ssid);

  Serial.println("Menghubungkan...");


  WiFi.mode(WIFI_STA);

  WiFi.disconnect(true);

  delay(1000);

  WiFi.begin(
    ssid,
    password
  );


  int attempt = 0;

  while (
    WiFi.status() != WL_CONNECTED &&
    attempt < 30
  ) {

    delay(500);

    Serial.print(".");

    attempt++;
  }


  Serial.println();


  // =================================================
  // BERHASIL
  // =================================================

  if (WiFi.status() == WL_CONNECTED) {

    Serial.println("WIFI TERHUBUNG!");

    Serial.print("SSID      : ");
    Serial.println(WiFi.SSID());

    Serial.print("IP ESP32  : ");
    Serial.println(WiFi.localIP());

    Serial.print("Gateway   : ");
    Serial.println(WiFi.gatewayIP());

    Serial.print("RSSI      : ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");

    Serial.println("========================================");

    return true;
  }


  // =================================================
  // GAGAL
  // =================================================

  Serial.println("WIFI GAGAL TERHUBUNG!");

  Serial.print("Status WiFi: ");
  Serial.println(WiFi.status());

  Serial.println("Periksa:");
  Serial.println("1. Nama WiFi");
  Serial.println("2. Password");
  Serial.println("3. Pastikan WiFi 2.4 GHz");
  Serial.println("4. Pastikan ESP32 berada dalam jangkauan WiFi");

  Serial.println("========================================");

  return false;
}


// =====================================================
// SETUP
// =====================================================

void setup() {

  Serial.begin(115200);

  delay(1000);


  // ===================================================
  // HEADER
  // ===================================================

  Serial.println();
  Serial.println();
  Serial.println("========================================");
  Serial.println("          ESP32 SMART FARM");
  Serial.println("========================================");


  // ===================================================
  // DHT
  // ===================================================

  dht.begin();


  // ===================================================
  // ULTRASONIC
  // ===================================================

  pinMode(
    TRIG_PIN,
    OUTPUT
  );

  pinMode(
    ECHO_PIN,
    INPUT
  );

  digitalWrite(
    TRIG_PIN,
    LOW
  );


  // ===================================================
  // RELAY POMPA AIR
  // ===================================================

  pinMode(
    RELAY_PUMP_PIN,
    OUTPUT
  );


  // ===================================================
  // RELAY POMPA PESTISIDA
  // ===================================================

  pinMode(
    RELAY_PESTICIDE_PIN,
    OUTPUT
  );


  // ===================================================
  // PASTIKAN KEDUA POMPA OFF SAAT BOOT
  // ===================================================

  pumpOFF();

  pesticideOFF();


  // ===================================================
  // WIFI
  // ===================================================

  bool wifiConnected = connectWiFi();


  if (!wifiConnected) {

    Serial.println();
    Serial.println("ESP32 TIDAK TERHUBUNG KE WIFI.");
    Serial.println("Server HTTP belum dijalankan.");

    return;
  }


  // ===================================================
  // HTTP ROUTES
  // ===================================================

  server.on(
    "/",
    HTTP_GET,
    handleRoot
  );


  server.on(
    "/status",
    HTTP_GET,
    handleStatus
  );


  // ===================================================
  // POMPA AIR
  // ===================================================

  server.on(
    "/pump/on",
    HTTP_GET,
    handlePumpOn
  );


  server.on(
    "/pump/off",
    HTTP_GET,
    handlePumpOff
  );


  // ===================================================
  // POMPA PESTISIDA
  // ===================================================

  server.on(
    "/pesticide/on",
    HTTP_GET,
    handlePesticideOn
  );


  server.on(
    "/pesticide/off",
    HTTP_GET,
    handlePesticideOff
  );


  // ===================================================
  // START SERVER
  // ===================================================

  server.begin();


  Serial.println();
  Serial.println("========================================");
  Serial.println("        HTTP SERVER AKTIF");
  Serial.println("========================================");

  Serial.println("Port       : 80");

  Serial.print("IP ESP32   : ");
  Serial.println(WiFi.localIP());

  Serial.println();

  Serial.println("Flutter:");

  Serial.print("GET http://");
  Serial.print(WiFi.localIP());
  Serial.println("/status");

  Serial.println();

  Serial.print("POMPA AIR ON  http://");
  Serial.print(WiFi.localIP());
  Serial.println("/pump/on");

  Serial.print("POMPA AIR OFF http://");
  Serial.print(WiFi.localIP());
  Serial.println("/pump/off");

  Serial.println();

  Serial.print("PESTISIDA ON  http://");
  Serial.print(WiFi.localIP());
  Serial.println("/pesticide/on");

  Serial.print("PESTISIDA OFF http://");
  Serial.print(WiFi.localIP());
  Serial.println("/pesticide/off");

  Serial.println("========================================");
}


// =====================================================
// LOOP
// =====================================================

void loop() {


  // ===================================================
  // HTTP CLIENT
  // ===================================================

  if (WiFi.status() == WL_CONNECTED) {

    server.handleClient();
  }


  // ===================================================
  // SENSOR UPDATE
  // ===================================================

  if (
    millis() - lastSensorRead >=
    SENSOR_INTERVAL
  ) {

    lastSensorRead = millis();

    readSensors();
  }
}
