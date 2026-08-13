/*
  CHILIGUARD IOT - NODE SENSOR ESP32 DEVKIT
  Sinkron dengan FastAPI (app.py) & Dashboard (index.html)

  Sensor aktif:
    - DHT22      GPIO 4   -> Suhu Udara (°C) & Kelembapan Udara (%)
    - HC-SR04    TRIG 16 / ECHO 17 -> Jarak Objek Daun (cm) [ultrasonik]
    - Baterai    ADC GPIO 35 -> Kapasitas Baterai (%) (divider tegangan)
    - Soil       ADC GPIO 34 -> Kelembapan Tanah (%) [capacitive, opsional]

  Alur: ESP32 -> POST form /update-telemetry -> FastAPI -> index.html & Flutter

  Pin servo robot arm (dipakai setelah konfigurasi menu kamera):
    Base 12 | Shoulder 14 | Elbow 27 | Gripper 13

  Board: ESP32 DevKit V1 | Arduino IDE (esp32 core)
  Library: DHT sensor library by Adafruit, DHT sensor library by Rob Tillaart
*/

#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

// ===== Konfigurasi Wi-Fi & Server =====
const char* SSID = "Kebun_Cabai_IoT_WiFi";
const char* WIFI_PASSWORD = "cabaimerah123";

// Base URL FastAPI. Contoh ngrok: https://xxxx.ngrok-free.dev
// Untuk jaringan lokal gunakan: http://192.168.1.100:8000
const char* SERVER_URL = "http://192.168.1.100:8000/update-telemetry";

// ===== Pin Sensor =====
#define DHT_PIN 4
#define DHT_TYPE DHT22
#define TRIG_PIN 16
#define ECHO_PIN 17
#define BATT_PIN 35   // ADC1_CH7
#define SOIL_PIN 34   // ADC1_CH6 (opsional)

#define TELEMETRY_INTERVAL_MS 3000

DHT dht(DHT_PIN, DHT_TYPE);

// Faktor pembagi tegangan baterai. Contoh: R1=100k & R2=100k -> factor = 2.0
const float VOLTAGE_DIVIDER = 2.0;
// Rentang tegangan pack Li-ion 3P (3.3V kosong - 4.2V penuh)
const float BATT_MIN_VOLT = 3.3;
const float BATT_MAX_VOLT = 4.2;

unsigned long lastSend = 0;

void setup() {
  Serial.begin(115200);
  dht.begin();
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(BATT_PIN, INPUT);
  pinMode(SOIL_PIN, INPUT);

  Serial.println("Menghubungkan Wi-Fi...");
  WiFi.mode(WIFI_STA);
  WiFi.begin(SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Terhubung! IP: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (millis() - lastSend >= TELEMETRY_INTERVAL_MS) {
    lastSend = millis();
    if (WiFi.status() == WL_CONNECTED) {
      sendTelemetry();
    }
  }
}

float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH);
  if (duration <= 0) return -1.0;
  float cm = duration * 0.0343 / 2.0;
  return (cm > 400.0) ? -1.0 : cm;
}

float readBatteryPercent() {
  int raw = analogRead(BATT_PIN);
  float voltage = (raw / 4095.0) * 3.3 * VOLTAGE_DIVIDER;
  float pct = ((voltage - BATT_MIN_VOLT) / (BATT_MAX_VOLT - BATT_MIN_VOLT)) * 100.0;
  if (pct > 100.0) pct = 100.0;
  if (pct < 0.0) pct = 0.0;
  return pct;
}

float readSoilPercent() {
  int raw = analogRead(SOIL_PIN);
  // Kapasitif: kering ~3500, basah ~1500 (sensor di dalam tanah)
  return map(raw, 3500, 1500, 0, 100);
}

void sendTelemetry() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();
  float dist = readDistanceCm();
  float batt = readBatteryPercent();
  float soil = readSoilPercent();

  if (isnan(temp) || isnan(hum)) {
    Serial.println("[ERROR] Gagal baca DHT22");
    temp = -999.0;
    hum = -999.0;
  }

  HTTPClient http;
  http.begin(SERVER_URL);
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");

  String body = "temp=" + String(temp) +
                "&hum=" + String(hum) +
                "&dist=" + String(dist, 1) +
                "&soil=" + String((int)soil) +
                "&batt=" + String((int)batt);

  int code = http.POST(body);
  Serial.printf("[TELEMETRI] temp=%.1f hum=%.1f dist=%.1f soil=%.0f batt=%.0f | HTTP %d\n",
                temp, hum, dist, soil, batt, code);
  http.end();
}
