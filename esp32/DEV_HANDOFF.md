# Handoff Developer App — Backend API

Dokumen acuan untuk tim mobile/admin agar terhubung ke data sensor dan cuaca melalui
Cloudflare Worker. Aplikasi **tidak perlu** akses langsung ke ESP32, Supabase, atau
Open-Meteo.

---

## 0. Base URL

Gunakan satu base URL API:

```text
https://sensor-monitor.aquaponic.workers.dev
```

Jika domain dashboard nanti dipasang ke Worker, base URL bisa menjadi:

```text
https://dashboard-domain.com
```

Endpoint API tetap berada di prefix `/api`.

Produksi yang direkomendasikan:

```text
https://dashboard-domain.com/        -> Admin Dashboard (Cloudflare Pages)
https://dashboard-domain.com/api/... -> Backend API (Cloudflare Worker)
```

---

## 1. Arsitektur

```text
ESP32 ──POST /api/sensor──> Cloudflare Worker ──> Supabase

Admin Dashboard ─┐
Mobile App      ─┴──Bearer token──> Cloudflare Worker API
                                      ├── Supabase sensor data
                                      └── Open-Meteo cuaca
```

Aturan role:

| Role | Hak akses |
|------|-----------|
| `admin` | baca data + ubah threshold/pengaturan |
| `user` | baca data sensor dan cuaca saja |

Role dibaca dari Supabase Auth user metadata:

```json
{
  "role": "admin"
}
```

Jika role tidak ada, Worker menganggap user sebagai `user`.

---

## 2. Secret Worker

Set lewat Wrangler, jangan commit ke file:

```bash
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_ANON_KEY
wrangler secret put SUPABASE_SERVICE_KEY
wrangler secret put DEVICE_API_KEY
```

Catatan:

- `SUPABASE_ANON_KEY` dipakai Worker untuk login dan validasi JWT.
- `SUPABASE_SERVICE_KEY` hanya ada di Worker untuk query database server-side.
- `DEVICE_API_KEY` hanya untuk ESP32 dan endpoint maintenance.

---

## 3. Autentikasi

### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password"
}
```

Response:

```json
{
  "token": "eyJhbGci...",
  "refresh_token": "...",
  "expires_in": 3600,
  "role": "user",
  "user": {
    "id": "...",
    "email": "user@example.com",
    "role": "user"
  }
}
```

Simpan `token`, lalu kirim di semua request berikutnya:

```http
Authorization: Bearer eyJhbGci...
```

### Cek User Aktif

```http
GET /api/auth/me
Authorization: Bearer <token>
```

### Logout

```http
POST /api/auth/logout
Authorization: Bearer <token>
```

---

## 4. Sensor API

### Daftar Device + Status Terbaru

```http
GET /api/devices
Authorization: Bearer <token>
```

Response:

```json
[
  {
    "device": "esp-01",
    "label": "Kolam 1",
    "status": "online",
    "reading": {
      "id": 123,
      "device": "esp-01",
      "temperature": 26.4,
      "ph": 7.21,
      "created_at": "2026-06-22T00:00:00Z"
    },
    "threshold": {
      "device": "esp-01",
      "ph_min": 6,
      "ph_max": 8.5,
      "temp_min": 0,
      "temp_max": 40
    }
  }
]
```

Status:

| Status | Arti |
|--------|------|
| `online` | data terbaru masih segar |
| `offline` | belum ada data atau data lebih dari 30 detik |
| `danger` | online, tapi suhu/pH di luar threshold |

### Live Satu Device

```http
GET /api/devices/esp-01/live
Authorization: Bearer <token>
```

### Riwayat Mentah

```http
GET /api/devices/esp-01/history?limit=50
Authorization: Bearer <token>
```

Parameter opsional:

```text
limit=1..500
from=2026-06-22T00:00:00Z
to=2026-06-23T00:00:00Z
```

### Sparkline

```http
GET /api/devices/esp-01/sparkline?limit=60
Authorization: Bearer <token>
```

### Grafik Agregat

```http
GET /api/devices/esp-01/series?bucket=hour&from=2026-06-22T00:00:00Z&to=2026-06-23T00:00:00Z
Authorization: Bearer <token>
```

`bucket`:

```text
minute | hour | day | month | year
```

Response tiap baris:

```json
{
  "t": "2026-06-22T00:00:00Z",
  "temp_avg": 26.1,
  "temp_min": 25.9,
  "temp_max": 26.4,
  "ph_avg": 7.2,
  "ph_min": 7.1,
  "ph_max": 7.3
}
```

---

## 5. Threshold API

### Baca Threshold

```http
GET /api/thresholds
Authorization: Bearer <token>
```

### Ubah Threshold

Khusus `admin`.

```http
PUT /api/thresholds/esp-01
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "ph_min": 6,
  "ph_max": 8.5,
  "temp_min": 20,
  "temp_max": 32
}
```

---

## 6. Cuaca API

Lokasi tetap: Gunungpati, Kota Semarang.

### Cuaca Saat Ini

```http
GET /api/weather/current
Authorization: Bearer <token>
```

### Prakiraan Per Jam

```http
GET /api/weather/hourly
Authorization: Bearer <token>
```

### Prakiraan Harian

```http
GET /api/weather/daily
Authorization: Bearer <token>
```

---

## 7. Admin User API

Endpoint ini khusus `admin`.

### Daftar User

```http
GET /api/admin/users
Authorization: Bearer <admin-token>
```

### Tambah User

```http
POST /api/admin/users
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "minimal6",
  "role": "user"
}
```

`role`:

```text
user | admin
```

### Ubah User

```http
PATCH /api/admin/users/:id
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "role": "admin"
}
```

Field yang bisa diubah:

```text
email
password
role
banned_until
```

Untuk blokir user:

```json
{ "banned_until": "2999-12-31T00:00:00Z" }
```

Untuk aktifkan kembali:

```json
{ "banned_until": null }
```

### Hapus User

```http
DELETE /api/admin/users/:id
Authorization: Bearer <admin-token>
```

---

## 8. ESP32 Ingestion

Endpoint ini hanya untuk perangkat ESP32.

```http
POST /api/sensor
X-API-Key: <DEVICE_API_KEY>
Content-Type: application/json

{
  "device": "esp-01",
  "readings": [
    {
      "t": "2026-06-22T00:00:00Z",
      "temperature": 26.4,
      "ph": 7.21
    }
  ]
}
```

---

## 9. Catatan Mobile

- Mobile app cukup menyimpan `baseUrl`, `token`, dan `refresh_token`.
- Semua timestamp dari API adalah UTC. Tampilkan sebagai WIB di UI.
- User mobile memakai role `user`.
- Admin dashboard memakai role `admin`.
- Mobile tidak boleh menyimpan Supabase service key, anon key, atau device API key.
