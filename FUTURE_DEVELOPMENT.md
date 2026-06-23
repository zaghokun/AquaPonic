# Pengembangan Ke Depan (Future Development)

Dokumen ini mencatat fitur-fitur UI yang sudah ada di aplikasi Mobile **AquaPonic** namun **belum terhubung ke Backend API** (Cloudflare Worker). Fitur-fitur ini saat ini masih menggunakan data dummy atau belum berfungsi secara nyata.

Catatan ini dibuat agar tim pengembang (Backend maupun Mobile) bisa melanjutkan integrasi di masa mendatang tanpa kehilangan konteks.

---

## Status Saat Ini

```text
Web Dashboard = Admin  (sudah terhubung penuh ke Worker API)
Mobile App    = User   (sebagian terhubung, sebagian masih dummy)
```

Base API:

```text
https://sensor-monitor.aquaponic.workers.dev/api
```

---

## Fitur yang Sudah Terhubung ke API

| Fitur | Layar | Endpoint |
|-------|-------|----------|
| Login | `login_screen.dart` | `POST /api/auth/login` |
| Dashboard Kolam | `sensor_main_screen.dart` | `GET /api/devices` |
| Detail Kolam & Grafik | `sensor_detail_screen.dart` | `GET /api/devices/:id/series` |
| Cuaca Saat Ini | `weather_main_screen.dart` | `GET /api/weather/current` |
| Cuaca Per Jam | `weather_main_screen.dart` | `GET /api/weather/hourly` |
| Cuaca Harian | `weather_daily_detail_screen.dart` | `GET /api/weather/daily` |

---

## Fitur yang Belum Terhubung (Masih Dummy)

### 1. Registrasi Akun (`register_screen.dart`)

**Status:** Tampilan UI sudah ada, tapi tombol Daftar belum terhubung ke server.

**Dibutuhkan:** Endpoint `POST /api/auth/register` di Worker.

**Catatan:** Saat ini pendaftaran akun hanya bisa dilakukan oleh Admin melalui Web Dashboard (`POST /api/admin/users`). Jika ke depan aplikasi mobile ingin membuka pendaftaran mandiri, Backend perlu menambahkan endpoint register publik.

---

### 2. Tambah Sensor (`add_sensor_screen.dart`)

**Status:** Tampilan UI sudah ada, tapi tombol Tambah belum terhubung ke server.

**Dibutuhkan:** Endpoint `POST /api/devices` di Worker.

**Catatan:** Saat ini perangkat sensor (esp-01 s/d esp-04) sudah di-hardcode di sisi server. Jika ke depan ingin menambah kolam/sensor secara dinamis, Backend perlu menambahkan endpoint untuk mengelola daftar device.

---

### 3. Riwayat Notifikasi (`notification_screen.dart`)

**Status:** Tab Notifikasi sudah ada di navigasi bawah, tapi isinya belum menampilkan data dari server.

**Dibutuhkan:** Endpoint `GET /api/notifications` di Worker.

**Catatan:** Saat ini Backend hanya memiliki Activity Log (`GET /api/admin/activity`) yang khusus untuk Admin. Untuk mobile, dibutuhkan endpoint notifikasi terpisah yang menampilkan riwayat peringatan seperti:
- Perangkat offline/terputus
- Suhu di luar batas aman
- pH di luar batas aman

---

### 4. Edit Profil & Ganti Password

**Status:** Tampilan UI sudah ada di menu Akun (Edit Profil, Ganti Kata Sandi, Ganti Email, Ganti Nomor Telepon), tapi belum terhubung ke server.

**Layar terkait:**
- `edit_profile_screen.dart`
- `change_password_screen.dart`
- `change_email_screen.dart`
- `change_phone_screen.dart`

**Dibutuhkan:**
- `PATCH /api/users/me` — untuk mengubah data profil (nama, email, nomor telepon).
- `PUT /api/users/me/password` — untuk mengganti password sendiri.

**Catatan:** Saat ini hanya Admin yang bisa mengubah data user melalui `PATCH /api/admin/users/:id`. User biasa belum memiliki endpoint untuk mengubah data dirinya sendiri.

---

### 5. Pengaturan Threshold (`settings_screen.dart`)

**Status:** Tampilan UI sudah ada dengan toggle dan input batas atas/bawah untuk suhu dan pH, tapi tombol simpan belum terhubung ke server.

**Dibutuhkan:** Akses endpoint `PUT /api/thresholds/:device` untuk role `user`.

**Catatan:** Saat ini endpoint tersebut hanya menerima token dengan role `admin`. Jika ke depan user biasa diizinkan mengatur batas aman kolamnya sendiri, Backend perlu membuka akses endpoint ini untuk role `user`, atau membuat endpoint terpisah.

---

## Ringkasan Endpoint yang Dibutuhkan

| No | Endpoint Baru | Untuk Fitur |
|----|---------------|-------------|
| 1 | `POST /api/auth/register` | Registrasi mandiri |
| 2 | `POST /api/devices` | Tambah sensor/kolam |
| 3 | `GET /api/notifications` | Riwayat notifikasi mobile |
| 4 | `PATCH /api/users/me` | Edit profil user |
| 5 | `PUT /api/users/me/password` | Ganti password user |
| 6 | `PUT /api/thresholds/:device` (buka untuk user) | Pengaturan threshold |

---

## Catatan Teknis

- Semua timestamp dari API adalah **UTC**. Tampilkan sebagai **WIB** (UTC+7) di UI mobile.
- Mobile app **tidak boleh** menyimpan Supabase service key, anon key, atau device API key.
- Mobile app hanya menyimpan `baseUrl`, `token`, dan `refresh_token`.
- Referensi kontrak API lengkap: `D:\project\Program_PLN\pln\esp32\DEV_HANDOFF.md`
