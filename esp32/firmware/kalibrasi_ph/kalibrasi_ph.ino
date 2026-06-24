/**
 * Baca pH via ADS1115 — ESP32-S3 N16R8 @ 3.3V
 *
 * Library: Adafruit ADS1X15 (Library Manager)
 *
 * Wiring (lihat WIRING_ADS1115.md):
 *   ADS1115 VDD->3V3, GND->GND, SCL->GPIO9, SDA->GPIO8, ADDR->GND (0x48)
 *   ADS1115 A0 <- Po (board pH).  Board pH: V+->3V3, G->GND.
 *
 * Sketch ini sekaligus dipakai untuk KALIBRASI:
 *   - Short BNC          -> catat Volt (pH 7.00) = V7
 *   - Celup buffer pH 4  -> catat Volt          = V4
 *   lalu hitung m & b (lihat WIRING_ADS1115.md).
 */

#include <Wire.h>
#include <Adafruit_ADS1X15.h>

Adafruit_ADS1115 ads;

// --- Pin I2C ESP32-S3 ---
#define I2C_SDA 8
#define I2C_SCL 9
#define ADS_ADDR 0x48      // ADDR -> GND

// --- Channel ADS1115 untuk pH ---
#define PH_CHANNEL 0       // A0

// --- Konstanta kalibrasi (hasil kalibrasi 3 titik buffer 4.00/6.86/9.18) ---
// Regresi linear. Ukur ulang bila ganti probe/board. Detail: kalibrasi_log.md
//   Semua dari TEGANGAN ASLI (screenshot Serial Monitor), buffer 4.00/6.86/9.18.
//   Ganti 2 baris float di bawah sesuai probe yang dipasang.
//   Sensor #1 (2026-06-20) : m = -7.736, b = 28.081  (err<0.04) <- aktif
//   Sensor #2 (2026-06-20) : m = -6.811, b = 25.383  (err<0.04)
//   Sensor #3 (2026-06-20) : m = -6.525, b = 24.035  (err<0.01)
//   Sensor #4 (2026-06-20) : m = -7.051, b = 25.482  (err<0.03)
float PH_SLOPE  = -6.811;  // m  (Sensor #1)
float PH_OFFSET = 25.383;  // b
//float PH_SLOPE  = -7.654;
//float PH_OFFSET = 27.530;
const int NUM_SAMPLES = 31;     // ganjil, untuk trimmed-mean
const float EMA_ALPHA = 0.1;    // 0..1 — makin kecil makin halus (tapi makin lambat)
float phEMA = NAN;              // state moving average

void setup() {
  Serial.begin(115200);
  delay(500);

  Wire.begin(I2C_SDA, I2C_SCL);

  if (!ads.begin(ADS_ADDR)) {
    Serial.println("[ADS1115] TIDAK TERDETEKSI! Cek wiring I2C & alamat.");
    while (1) delay(100);
  }
  // ±4.096V, 0.125 mV/bit — cukup untuk sinyal pH 0..3.3V
  ads.setGain(GAIN_ONE);

  Serial.println("=== Baca pH via ADS1115 ===");
  Serial.println("Format: Volt | pH");
  Serial.println("(saat kalibrasi, fokus ke kolom Volt)");
  Serial.println("---------------------------");
}

// Trimmed-mean: ambil banyak sampel, urutkan, buang 25% terendah & tertinggi,
// rata-rata sisanya. Tahan terhadap spike noise.
float readVoltage() {
  float v[NUM_SAMPLES];
  for (int i = 0; i < NUM_SAMPLES; i++) {
    v[i] = ads.computeVolts(ads.readADC_SingleEnded(PH_CHANNEL));
    delay(8);
  }

  // urutkan (insertion sort, cukup untuk N kecil)
  for (int i = 1; i < NUM_SAMPLES; i++) {
    float key = v[i];
    int j = i - 1;
    while (j >= 0 && v[j] > key) { v[j + 1] = v[j]; j--; }
    v[j + 1] = key;
  }

  // buang 25% tepi, rata-rata bagian tengah
  int lo = NUM_SAMPLES / 4;
  int hi = NUM_SAMPLES - lo;
  float sum = 0;
  int   cnt = 0;
  for (int i = lo; i < hi; i++) { sum += v[i]; cnt++; }
  return sum / cnt;
}

void loop() {
  float voltage = readVoltage();
  float ph = PH_SLOPE * voltage + PH_OFFSET;

  // Moving average (EMA) untuk pembacaan akhir yang halus
  if (isnan(phEMA)) phEMA = ph;
  else              phEMA = EMA_ALPHA * ph + (1.0 - EMA_ALPHA) * phEMA;

  Serial.printf("V: %.4f V  |  pH(raw): %.2f  |  pH(halus): %.2f\n",
                voltage, ph, phEMA);

  delay(500);
}
