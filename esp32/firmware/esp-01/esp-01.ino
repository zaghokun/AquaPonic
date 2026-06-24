/**
 * esp-01 — ESP32-S3 -> Cloudflare Worker -> Supabase  (pH via ADS1115)
 *
 * MODE PER-DETIK + BATCH:
 *   - Rekam suhu + pH setiap 1 detik (dengan timestamp NTP)
 *   - Kirim 10 rekaman sekaligus tiap 10 detik (hemat koneksi HTTPS)
 *
 * Library: OneWire, DallasTemperature, Adafruit ADS1X15
 * Wiring : lihat WIRING_ADS1115.md (DS18B20 GPIO4; ADS1115 SDA8/SCL9/0x48, A0<-Po)
 */

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <Adafruit_ADS1X15.h>
#include <time.h>

// =====================================================
//  KONFIGURASI — ubah per unit
// =====================================================
const char* WIFI_SSID     = "AXL";
const char* WIFI_PASSWORD = "GunNRoses";

const char* WORKER_URL     = "https://sensor-monitor.aquaponic.workers.dev/api/sensor";
const char* DEVICE_API_KEY = "PeTImlPYZj4exKFr7X7YQv9H3XdvSDOT68Hryi0+tos=";   // kunci bersama (SAMA di semua unit, cocok secret Worker)

const char* DEVICE_ID = "esp-01";         // identitas unik (BEDA tiap unit)

// --- Konstanta kalibrasi pH (lihat kalibrasi_log.md) ---
const float PH_SLOPE  = -7.736;  // m
const float PH_OFFSET = 28.081;  // b

const int SAMPLE_INTERVAL_MS = 1000;  // rekam tiap 1 detik
const int BATCH_SIZE         = 10;    // kirim tiap 10 rekaman (=10 detik)
// =====================================================

// NTP (UTC) — timestamp tiap rekaman
const char* NTP_SERVER1 = "pool.ntp.org";
const char* NTP_SERVER2 = "time.google.com";

// --- DS18B20 (GPIO 4) ---
#define ONE_WIRE_BUS 4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);

// --- ADS1115 (I2C) untuk pH ---
Adafruit_ADS1115 ads;
#define I2C_SDA     8
#define I2C_SCL     9
#define ADS_ADDR    0x48
#define PH_CHANNEL  0
const int PH_NUM_SAMPLES = 31;

// --- Buffer batch ---
struct Reading { time_t ts; float temp; float ph; };
Reading buf[BATCH_SIZE];
int bufCount = 0;
unsigned long lastSample = 0;

// =====================================================
void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println("================================");
  Serial.printf ("  esp [%s] - mode per-detik+batch\n", DEVICE_ID);
  Serial.println("================================");

  tempSensor.begin();
  tempSensor.setResolution(10);  // 10-bit ~187ms, cukup cepat untuk per-detik
  Serial.println("[DS18B20] initialized.");

  Wire.begin(I2C_SDA, I2C_SCL);
  if (!ads.begin(ADS_ADDR)) {
    Serial.println("[ADS1115] TIDAK TERDETEKSI! Cek wiring I2C & alamat.");
    while (1) delay(100);
  }
  ads.setGain(GAIN_ONE);
  Serial.println("[ADS1115] initialized.");

  connectWiFi();

  // Sinkronisasi waktu (UTC)
  configTime(0, 0, NTP_SERVER1, NTP_SERVER2);
  Serial.print("[NTP] sync");
  struct tm ti;
  while (!getLocalTime(&ti, 1000)) Serial.print(".");
  Serial.println(" ok");
}

void connectWiFi() {
  Serial.printf("[WiFi] Connecting to %s", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println();
  Serial.printf("[WiFi] Connected! IP: %s\n", WiFi.localIP().toString().c_str());
}

// =====================================================
// Trimmed-mean: 31 sampel, buang 25% tepi, rata-rata sisanya.
float readPHVoltage() {
  float v[PH_NUM_SAMPLES];
  for (int i = 0; i < PH_NUM_SAMPLES; i++) {
    v[i] = ads.computeVolts(ads.readADC_SingleEnded(PH_CHANNEL));
    delay(6);
  }
  for (int i = 1; i < PH_NUM_SAMPLES; i++) {
    float key = v[i]; int j = i - 1;
    while (j >= 0 && v[j] > key) { v[j + 1] = v[j]; j--; }
    v[j + 1] = key;
  }
  int lo = PH_NUM_SAMPLES / 4, hi = PH_NUM_SAMPLES - (PH_NUM_SAMPLES / 4);
  float sum = 0; int cnt = 0;
  for (int i = lo; i < hi; i++) { sum += v[i]; cnt++; }
  return sum / cnt;
}

// =====================================================
bool sendBatch() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[WiFi] Disconnected, reconnecting...");
    WiFi.reconnect();
    return false;
  }

  WiFiClientSecure client;
  client.setInsecure();

  HTTPClient http;
  if (!http.begin(client, WORKER_URL)) {
    Serial.println("[HTTP] begin() gagal");
    return false;
  }
  http.addHeader("Content-Type", "application/json");
  http.addHeader("X-API-Key", DEVICE_API_KEY);

  // Bangun JSON: {"device":"esp-01","readings":[{"t":"...","temperature":..,"ph":..},...]}
  String body = String("{\"device\":\"") + DEVICE_ID + "\",\"readings\":[";
  char tsbuf[25];
  for (int i = 0; i < bufCount; i++) {
    struct tm g; gmtime_r(&buf[i].ts, &g);
    strftime(tsbuf, sizeof(tsbuf), "%Y-%m-%dT%H:%M:%SZ", &g);
    if (i) body += ",";
    body += "{\"t\":\"" + String(tsbuf) + "\",\"temperature\":";
    body += (buf[i].temp == -127.00) ? "null" : String(buf[i].temp, 2);
    body += ",\"ph\":" + String(buf[i].ph, 2) + "}";
  }
  body += "]}";

  int code = http.POST(body);
  bool ok = (code == 200 || code == 201);
  if (ok) Serial.printf("[HTTP] batch %d rekaman OK (code %d)\n", bufCount, code);
  else    Serial.printf("[HTTP] batch GAGAL (code %d): %s\n", code, http.getString().c_str());
  http.end();
  return ok;
}

// =====================================================
void loop() {
  if (millis() - lastSample >= (unsigned long)SAMPLE_INTERVAL_MS) {
    lastSample = millis();

    float v  = readPHVoltage();
    float ph = PH_SLOPE * v + PH_OFFSET;
    tempSensor.requestTemperatures();
    float t  = tempSensor.getTempCByIndex(0);
    time_t now = time(nullptr);

    buf[bufCount].ts   = now;
    buf[bufCount].temp = t;
    buf[bufCount].ph   = ph;
    bufCount++;

    Serial.printf("[rec %d/%d] t=%.2f C  ph=%.2f\n", bufCount, BATCH_SIZE, t, ph);

    if (bufCount >= BATCH_SIZE) {
      sendBatch();
      bufCount = 0;  // buffer dikosongkan (batch gagal dibuang agar tidak overflow)
    }
  }
  delay(5);
}
