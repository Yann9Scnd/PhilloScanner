#include <WiFi.h>
#include <WebServer.h>
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
// STATUS
// =====================================================

bool pumpState = false;

float temperature = 0;
float humidity = 0;
float distance = 0;

int soilRaw = 0;
int soilPercent = 0;

unsigned long lastSensorRead = 0;

const unsigned long SENSOR_INTERVAL = 3000;


// =====================================================
// RELAY
// =====================================================

// Untuk relay ACTIVE HIGH
void pumpON() {

  digitalWrite(RELAY_PIN, HIGH);

  pumpState = true;

  Serial.println("POMPA -> ON");
}


void pumpOFF() {

  digitalWrite(RELAY_PIN, LOW);

  pumpState = false;

  Serial.println("POMPA -> OFF");
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

  return duration * 0.0343 / 2.0;
}


// =====================================================
// BACA SENSOR
// =====================================================

void readSensors() {

  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  if (!isnan(temp)) {
    temperature = temp;
  }

  if (!isnan(hum)) {
    humidity = hum;
  }


  // Ultrasonic

  distance = readDistance();


  // Soil

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


  // Serial monitor

  Serial.println();
  Serial.println("================================");

  Serial.println("SENSOR UPDATE");

  Serial.print("Temperature : ");
  Serial.print(temperature);
  Serial.println(" C");

  Serial.print("Humidity    : ");
  Serial.print(humidity);
  Serial.println(" %");

  Serial.print("Distance    : ");
  Serial.print(distance);
  Serial.println(" cm");

  Serial.print("Soil RAW    : ");
  Serial.println(soilRaw);

  Serial.print("Soil        : ");
  Serial.print(soilPercent);
  Serial.println(" %");

  Serial.print("Pump        : ");
  Serial.println(
    pumpState ? "ON" : "OFF"
  );

  Serial.println("================================");
}


// =====================================================
// GET /status
// =====================================================

void handleStatus() {

  String json = "{";

  json += "\"temperature\":" + String(temperature, 1) + ",";
  json += "\"humidity\":" + String(humidity, 0) + ",";
  json += "\"distance\":" + String(distance, 1) + ",";
  json += "\"soilRaw\":" + String(soilRaw) + ",";
  json += "\"soil\":" + String(soilPercent) + ",";
  json += "\"pump\":" + String(
    pumpState ? "true" : "false"
  );

  json += "}";

  server.send(
    200,
    "application/json",
    json
  );
}


// =====================================================
// GET /pump/on
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
// GET /pump/off
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
// GET /
// =====================================================

void handleRoot() {

  String message = "";

  message += "ESP32 SMART FARM";
  message += "\n\n";
  message += "Available endpoints:";
  message += "\n";
  message += "GET /status";
  message += "\n";
  message += "GET /pump/on";
  message += "\n";
  message += "GET /pump/off";

  server.send(
    200,
    "text/plain",
    message
  );
}


// =====================================================
// SETUP
// =====================================================

void setup() {

  Serial.begin(115200);

  delay(1000);


  // Sensor

  dht.begin();


  // Ultrasonic

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  digitalWrite(TRIG_PIN, LOW);


  // Relay

  pinMode(RELAY_PIN, OUTPUT);

  pumpOFF();


  // WiFi

  Serial.println();
  Serial.println("================================");
  Serial.println("ESP32 SMART FARM");
  Serial.println("================================");

  Serial.println("Menghubungkan WiFi...");

  WiFi.begin(
    ssid,
    password
  );


  while (WiFi.status() != WL_CONNECTED) {

    delay(500);

    Serial.print(".");
  }


  Serial.println();
  Serial.println("WiFi TERHUBUNG");

  Serial.print("IP ESP32: ");
  Serial.println(WiFi.localIP());


  // Server routes

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


  server.begin();

  Serial.println();
  Serial.println("HTTP SERVER AKTIF");
  Serial.println("Port: 80");

  Serial.println();
  Serial.println("Gunakan IP ESP32 di Flutter:");
  Serial.println(WiFi.localIP());

  Serial.println("================================");
}


// =====================================================
// LOOP
// =====================================================

void loop() {

  server.handleClient();


  // Sensor update setiap 3 detik

  if (
    millis() - lastSensorRead >= SENSOR_INTERVAL
  ) {

    lastSensorRead = millis();

    readSensors();
  }
}
