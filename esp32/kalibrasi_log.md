# Log Kalibrasi Sensor pH

Catatan konstanta kalibrasi tiap probe pH (ADS1115 @ 3.3V, ESP32-S3 N16R8).
Rumus: `pH = m × Volt + b`  →  `PH_SLOPE = m`, `PH_OFFSET = b`.

Buffer standar yang dipakai: **pH 4.00 / 6.86 / 9.18**.
Konstanta dihitung via regresi linear 3 titik (titik tengah rentang bacaan).

> Probe pH wajar mengalami drift seiring pemakaian. Kalibrasi ulang berkala
> (mis. tiap 2–4 minggu, atau saat bacaan terasa meleset).

---

## Sensor #1

| Tanggal | V@pH4 | V@pH6.86 | V@pH9.18 | m (slope) | b (offset) | Error | Status |
|---------|-------|----------|----------|-----------|-----------|-------|--------|
| (awal)     | —      | —      | —      | -7.654 | 27.530 | <0.05 | drift  |
| 2026-06-19 | 3.0750 | 2.7350 | 2.4350 | -8.101 | 28.943 | <0.07 | diganti |
| 2026-06-20 | 3.1100 | 2.7480 | 2.4400 | **-7.736** | **28.081** | <0.04 | ✅ aktif (V asli) |

Catatan: baris 2026-06-20 dari TEGANGAN ASLI (Sensor1_pH4/6.86/9.18.png).

---

## Sensor #2

| Tanggal | V@pH4 | V@pH6.86 | V@pH9.18 | m (slope) | b (offset) | Error | Status |
|---------|-------|----------|----------|-----------|-----------|-------|--------|
| 2026-06-19 | 3.1200 | 2.7300 | 2.3850 | -7.054 | 26.043 | <0.07 | diganti |
| 2026-06-20 | 3.1370 | 2.7250 | 2.3760 | **-6.811** | **25.383** | <0.04 | ✅ aktif (V asli) |

Catatan: baris 2026-06-20 dari TEGANGAN ASLI (Sensor2_pH4/6.86/9.18.png).

---

## Sensor #3

| Tanggal | V@pH4 | V@pH6.86 | V@pH9.18 | m (slope) | b (offset) | Error | Status |
|---------|-------|----------|----------|-----------|-----------|-------|--------|
| 2026-06-19 | 3.0750 | 2.6408 | 2.2705 | -6.443 | 23.833 | <0.04 | balik-hitung |
| 2026-06-20 | 3.0700 | 2.6330 | 2.2760 | **-6.525** | **24.035** | <0.01 | ✅ aktif (V asli) |

Catatan: baris 2026-06-20 dihitung dari TEGANGAN ASLI (screenshot Serial Monitor
Sensor3_pH4.png / Sensor3_pH6.86.png / Sensor3_pH9.18.png), bukan balik-hitung.
Fit terbaik dari semua sensor (error <0.01 pH).

---

## Sensor #4

| Tanggal | V@pH4 | V@pH6.86 | V@pH9.18 | m (slope) | b (offset) | Error | Status |
|---------|-------|----------|----------|-----------|-----------|-------|--------|
| 2026-06-19 | 3.0394 | 2.6398 | 2.3169 | -7.169 | 25.788 | <0.02 | balik-hitung |
| 2026-06-20 | 3.0450 | 2.6450 | 2.3100 | **-7.051** | **25.482** | <0.03 | ✅ aktif (V asli) |

Catatan: baris 2026-06-20 dihitung dari TEGANGAN ASLI (screenshot Serial Monitor
Sensor4_pH4.png / Sensor4_pH9koma18.png + bacaan pH6.86), bukan balik-hitung.
Ini nilai paling tepercaya untuk Sensor #4.

---

## Pemetaan Sensor → Device (untuk rencana 4 ESP)

Isi saat tiap unit dirakit. Tiap ESP di-flash dengan m & b probe-nya sendiri.

| Device ID | Sensor | m (slope) | b (offset) | Lokasi | Catatan |
|-----------|--------|-----------|-----------|--------|---------|
| esp-01 | #1 | -7.736 | 28.081 | (isi)  | (isi)   |
| esp-02 | #2 | -6.811 | 25.383 | (isi)  | (isi)   |
| esp-03 | #3 | -6.525 | 24.035 | (isi)  | (isi)   |
| esp-04 | #4 | -7.051 | 25.482 | (isi)  | (isi)   |

---

## Cara kalibrasi (ringkas)

1. Flash `baca_ph_ads1115/baca_ph_ads1115.ino`, buka Serial Monitor 115200.
2. Celup probe ke tiap buffer (4.00 → 6.86 → 9.18), bilas+keringkan tiap pindah.
3. Tunggu kolom `V:` stabil, catat tegangannya.
4. Hitung regresi linear 3 titik → dapat m & b.
5. Masukkan ke `PH_SLOPE` & `PH_OFFSET`, catat di tabel atas.

Rumus 2 titik (bila hanya pH 4 & pH 9.18):
```
m = (4.00 - 9.18) / (V4 - V9)
b = 4.00 - m × V4
```
