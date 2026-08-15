#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

// Bus I2C Terpisah
TwoWire I2C_Kiri  = TwoWire(0);
TwoWire I2C_Kanan = TwoWire(1);

#define OLED_ADDR 0x3C  

Adafruit_SSD1306 displayLeft(SCREEN_WIDTH, SCREEN_HEIGHT, &I2C_Kiri, -1);
Adafruit_SSD1306 displayRight(SCREEN_WIDTH, SCREEN_HEIGHT, &I2C_Kanan, -1);

// Pin Definition Sensor
#define TRIG_PIN 5
#define ECHO_PIN 18
#define DHTPIN   4
#define DHTTYPE  DHT11  // Ubah ke DHT22 jika Anda menggunakan modul DHT22
#define SOIL_PIN 34     // Pin Analog ADC1_CH6 (Aman saat WiFi aktif)

// Pin Definition Tambahan (Laser & LED)
#define LASER_PIN         15  // Pin Signal Modul Laser 3 Kaki
#define LED_ALWAYS_ON_PIN 32  // Pin LED yang selalu menyala

// Kalibrasi Sensor Kelembaban Tanah (Nilai Mentah ADC)
const int AIR_VALUE   = 3200; // Nilai ADC saat sensor kering di udara (0%)
const int WATER_VALUE = 1500; // Nilai ADC saat sensor dicelupkan ke air (100%)

DHT dht(DHTPIN, DHTTYPE);

String penyakitAI = "Memuat...";
String akurasiAI  = "0.00%";

unsigned long lastSensorSend = 0;

// Variabel Waktu & Status Laser Non-Blocking
unsigned long lastLaserToggle = 0;
bool laserState = LOW;

// Fungsi konversi pembacaan Analog Soil Moisture ke Persentase (0-100%)
int readSoilMoisture() {
  int rawAnalog = analogRead(SOIL_PIN);
  int percentage = map(rawAnalog, AIR_VALUE, WATER_VALUE, 0, 100);
  if (percentage > 100) percentage = 100;
  if (percentage < 0) percentage = 0;
  return percentage;
}

void setup() {
  // Serial Debugging
  Serial.begin(115200);
  
  // Serial2 Hardware UART (RX2 = Pin 26, TX2 = Pin 27)
  Serial2.begin(115200, SERIAL_8N1, 26, 27);

  // Perbaikan Pin I2C_Kiri: GPIO 19 (SDA) & GPIO 23 (SCL)
  I2C_Kiri.begin(19, 23, 100000);
  I2C_Kanan.begin(21, 22, 100000);
  delay(300);

  dht.begin();
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Inisialisasi Pin Laser & LED
  pinMode(LASER_PIN, OUTPUT);
  pinMode(LED_ALWAYS_ON_PIN, OUTPUT);
  
  // Menyalakan LED secara permanen
  digitalWrite(LED_ALWAYS_ON_PIN, HIGH);

  displayLeft.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR);
  displayRight.begin(SSD1306_SWITCHCAPVCC, OLED_ADDR);
}

void loop() {
  // 0. Logika Laser Berkedip Tiap 1 Detik (1000 ms) Non-Blocking
  if (millis() - lastLaserToggle >= 1000) {
    lastLaserToggle = millis();
    laserState = !laserState;
    digitalWrite(LASER_PIN, laserState);
  }

  // 1. Terima Hasil AI dari ESP32-CAM via UART2
  if (Serial2.available() > 0) {
    String incomingData = Serial2.readStringUntil('\n');
    incomingData.trim();
    int commaIdx = incomingData.indexOf(',');
    if (commaIdx > 0) {
      penyakitAI = incomingData.substring(0, commaIdx);
      akurasiAI  = incomingData.substring(commaIdx + 1);
    }
  }

  // 2. Baca Sensor Ultrasonik HC-SR04
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  
  long duration = pulseIn(ECHO_PIN, HIGH, 20000); 
  float jarakCm = (duration == 0) ? -1.0 : (duration * 0.034 / 2.0);

  // 3. Baca DHT & Soil Moisture
  float temp = dht.readTemperature();
  float hum  = dht.readHumidity();
  int soilPercent = readSoilMoisture();

  // 4. Kirim Data Sensor ke ESP32-CAM via UART2 tiap 500 ms (Format: Suhu,Kelembaban,Jarak,Tanah)
  if (millis() - lastSensorSend >= 500) {
    lastSensorSend = millis();
    String sensorMsg = String(isnan(temp) ? 0 : temp, 1) + "," + 
                       String(isnan(hum) ? 0 : hum, 0) + "," + 
                       String(jarakCm < 0 ? 0 : jarakCm, 1) + "," + 
                       String(soilPercent) + "\n";
    Serial2.print(sensorMsg);
  }

  // 5. Render OLED Kiri (Diagnosa AI)
  displayLeft.clearDisplay();
  displayLeft.fillRect(0, 0, 128, 14, SSD1306_WHITE);
  displayLeft.setTextColor(SSD1306_BLACK);
  displayLeft.setCursor(20, 3);
  displayLeft.print(F("DIAGNOSA AI"));
  
  displayLeft.setTextColor(SSD1306_WHITE);
  displayLeft.setCursor(0, 20);
  displayLeft.print(F("Penyakit:"));
  displayLeft.setCursor(0, 32);
  displayLeft.println(penyakitAI);
  displayLeft.setCursor(0, 50);
  displayLeft.print(F("Akurasi : "));
  displayLeft.println(akurasiAI);
  displayLeft.display();

  // 6. Render OLED Kanan (Sensor Monitor - 4 Data)
  displayRight.clearDisplay();
  displayRight.fillRect(0, 0, 128, 14, SSD1306_WHITE);
  displayRight.setTextColor(SSD1306_BLACK);
  displayRight.setCursor(15, 3);
  displayRight.print(F("SENSOR MONITOR"));
  
  displayRight.setTextColor(SSD1306_WHITE);
  
  // Baris 1: Jarak Daun
  displayRight.setCursor(0, 18);
  displayRight.print(F("Jrk Daun : "));
  if (jarakCm < 0) displayRight.println(F("Out Range"));
  else { displayRight.print(jarakCm, 1); displayRight.println(F(" cm")); }
  
  // Baris 2: Suhu Udara
  displayRight.setCursor(0, 30);
  displayRight.print(F("Suhu Udh : "));
  if (isnan(temp)) displayRight.println(F("Err"));
  else { displayRight.print(temp, 1); displayRight.println(F(" C")); }

  // Baris 3: Kelembaban Udara
  displayRight.setCursor(0, 42);
  displayRight.print(F("Kelem.Udh: "));
  if (isnan(hum)) displayRight.println(F("Err"));
  else { displayRight.print(hum, 0); displayRight.println(F(" %")); }

  // Baris 4: Kelembaban Tanah
  displayRight.setCursor(0, 54);
  displayRight.print(F("Kelem.Tnh: "));
  displayRight.print(soilPercent);
  displayRight.println(F(" %"));

  displayRight.display();

  delay(50);
}