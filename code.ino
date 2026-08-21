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
// SERVER LARAVEL
// =====================================================

const char* laravelUrl = "http://192.168.43.182:8000/api/telemetry";


// =====================================================
// PIN
// =====================================================

#define DHTPIN 4
#define DHTTYPE DHT11

#define RELAY_PIN 26

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

bool pumpState = false;

float temperature = 0;
float humidity = 0;
float distance = 0;

int soilRaw = 0;
int soilPercent = 0;


// =====================================================
// TIMER
// =====================================================

unsigned long lastSensorRead = 0;
unsigned long lastTelemetryPost = 0;

const unsigned long SENSOR_INTERVAL = 3000;
const unsigned long TELEMETRY_INTERVAL = 5000;


// =====================================================
// RELAY
// =====================================================

void pumpON() {
  digitalWrite(RELAY_PIN, HIGH);
  pumpState = true;
  Serial.println();
  Serial.println(">>> POMPA ON");
}

void pumpOFF() {
  digitalWrite(RELAY_PIN, LOW);
  pumpState = false;
  Serial.println();
  Serial.println(">>> POMPA OFF");
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

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);

  if (duration == 0) {
    return 0;
  }

  return duration * 0.0343 / 2.0;
}


// =====================================================
// BACA SEMUA SENSOR
// =====================================================

void readSensors() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (!isnan(temp)) temperature = temp;
  if (!isnan(hum)) humidity = hum;

  distance = readDistance();

  soilRaw = analogRead(SOIL_PIN);
  soilPercent = map(soilRaw, 3200, 1500, 0, 100);
  soilPercent = constrain(soilPercent, 0, 100);

  Serial.println();
  Serial.println("========================================");
  Serial.println("             SENSOR UPDATE");
  Serial.println("========================================");
  Serial.print("Temperature : "); Serial.print(temperature, 1); Serial.println(" C");
  Serial.print("Humidity    : "); Serial.print(humidity, 0); Serial.println(" %");
  Serial.print("Distance    : "); Serial.print(distance, 1); Serial.println(" cm");
  Serial.print("Soil RAW    : "); Serial.println(soilRaw);
  Serial.print("Soil        : "); Serial.print(soilPercent); Serial.println(" %");
  Serial.print("Pump        : "); Serial.println(pumpState ? "ON" : "OFF");
  Serial.println("========================================");
}


// =====================================================
// POST TELEMETRY KE LARAVEL
// =====================================================

void postTelemetry() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(laravelUrl);
  http.addHeader("Content-Type", "application/json");

  String json = "{";
  json += "\"temp\":" + String(temperature, 1) + ",";
  json += "\"hum\":" + String(humidity, 0) + ",";
  json += "\"dist\":" + String(distance, 1) + ",";
  json += "\"soil\":" + String(soilPercent) + ",";
  json += "\"batt\":0";
  json += "}";

  int code = http.POST(json);

  if (code > 0) {
    Serial.println("[LARAVEL] Telemetry terkirim: " + String(code));
  } else {
    Serial.println("[LARAVEL] Gagal kirim: " + String(code));
  }

  http.end();
}


// =====================================================
// HTTP HANDLERS
// =====================================================

void handleRoot() {
  String message = "ESP32 SMART FARM\n";
  message += "==============================\n";
  message += "ESP32 ONLINE\n\n";
  message += "Endpoints:\n";
  message += "GET /status\n";
  message += "GET /pump/on\n";
  message += "GET /pump/off\n";
  server.send(200, "text/plain", message);
}

void handleStatus() {
  String json = "{";
  json += "\"temperature\":" + String(temperature, 1) + ",";
  json += "\"humidity\":" + String(humidity, 0) + ",";
  json += "\"distance\":" + String(distance, 1) + ",";
  json += "\"soilRaw\":" + String(soilRaw) + ",";
  json += "\"soil\":" + String(soilPercent) + ",";
  json += "\"pump\":" + String(pumpState ? "true" : "false");
  json += "}";
  server.send(200, "application/json", json);
}

void handlePumpOn() {
  pumpON();
  server.send(200, "application/json", "{\"success\":true,\"pump\":true}");
}

void handlePumpOff() {
  pumpOFF();
  server.send(200, "application/json", "{\"success\":true,\"pump\":false}");
}


// =====================================================
// WIFI CONNECTION
// =====================================================

bool connectWiFi() {
  Serial.println();
  Serial.println("========================================");
  Serial.println("             WIFI CONNECTION");
  Serial.println("========================================");
  Serial.print("SSID     : "); Serial.println(ssid);
  Serial.println("Menghubungkan...");

  WiFi.mode(WIFI_STA);
  WiFi.disconnect(true);
  delay(1000);
  WiFi.begin(ssid, password);

  int attempt = 0;
  while (WiFi.status() != WL_CONNECTED && attempt < 30) {
    delay(500);
    Serial.print(".");
    attempt++;
  }

  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("WIFI TERHUBUNG!");
    Serial.print("SSID      : "); Serial.println(WiFi.SSID());
    Serial.print("IP ESP32  : "); Serial.println(WiFi.localIP());
    Serial.print("Gateway   : "); Serial.println(WiFi.gatewayIP());
    Serial.print("RSSI      : "); Serial.print(WiFi.RSSI()); Serial.println(" dBm");
    Serial.println("========================================");
    return true;
  }

  Serial.println("WIFI GAGAL TERHUBUNG!");
  Serial.print("Status WiFi: "); Serial.println(WiFi.status());
  Serial.println("========================================");
  return false;
}


// =====================================================
// SETUP
// =====================================================

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("========================================");
  Serial.println("          ESP32 SMART FARM");
  Serial.println("========================================");

  dht.begin();

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  digitalWrite(TRIG_PIN, LOW);

  pinMode(RELAY_PIN, OUTPUT);
  pumpOFF();

  bool wifiConnected = connectWiFi();

  if (!wifiConnected) {
    Serial.println("ESP32 TIDAK TERHUBUNG KE WIFI.");
    return;
  }

  server.on("/", HTTP_GET, handleRoot);
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/pump/on", HTTP_GET, handlePumpOn);
  server.on("/pump/off", HTTP_GET, handlePumpOff);
  server.begin();

  Serial.println();
  Serial.println("========================================");
  Serial.println("        HTTP SERVER AKTIF");
  Serial.println("========================================");
  Serial.println("Port       : 80");
  Serial.print("IP ESP32   : "); Serial.println(WiFi.localIP());
  Serial.println("========================================");
}


// =====================================================
// LOOP
// =====================================================

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    server.handleClient();
  }

  if (millis() - lastSensorRead >= SENSOR_INTERVAL) {
    lastSensorRead = millis();
    readSensors();
  }

  if (millis() - lastTelemetryPost >= TELEMETRY_INTERVAL &&
      WiFi.status() == WL_CONNECTED) {
    lastTelemetryPost = millis();
    postTelemetry();
  }
}
