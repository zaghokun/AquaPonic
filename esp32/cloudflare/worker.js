/**
 * Cloudflare Worker — backend API sensor/cuaca + arsip CSV harian ke R2
 *
 * Secret (wrangler secret put ...):
 *   SUPABASE_URL          : https://xxxx.supabase.co
 *   SUPABASE_ANON_KEY     : anon public key (untuk Supabase Auth)
 *   SUPABASE_SERVICE_KEY  : service_role key (RAHASIA, bypass RLS)
 *   DEVICE_API_KEY        : kunci validasi ESP
 *
 * Binding (wrangler.toml):
 *   ARCHIVE : R2 bucket (sensor-archive) untuk file CSV harian
 *
 * Cron (wrangler.toml): tiap 10 menit -> flush data baru ke CSV + purge >2 hari.
 *
 * Endpoint:
 *   POST /api/sensor                       -> ESP kirim data sensor (X-API-Key)
 *   POST /api/auth/login                   -> login admin/user
 *   POST /api/auth/refresh                 -> tukar refresh_token -> access token baru
 *   POST /api/auth/logout                  -> logout sesi
 *   GET  /api/auth/me                      -> profil token aktif
 *   GET  /api/devices                      -> data terbaru semua device
 *   GET  /api/devices/:id/live             -> data terbaru satu device
 *   GET  /api/devices/:id/history          -> riwayat mentah
 *   GET  /api/devices/:id/series           -> data grafik get_series()
 *   GET  /api/devices/:id/sparkline        -> N titik terakhir
 *   GET  /api/thresholds                   -> ambang batas
 *   PUT  /api/thresholds/:device           -> ubah ambang batas (admin)
 *   GET  /api/weather/current              -> cuaca saat ini
 *   GET  /api/weather/hourly               -> prakiraan per jam
 *   GET  /api/weather/daily                -> prakiraan harian
 *   GET  /api/admin/users                  -> daftar user (admin)
 *   POST /api/admin/users                  -> tambah user (admin)
 *   PATCH /api/admin/users/:id             -> ubah role/status/password (admin)
 *   DELETE /api/admin/users/:id            -> hapus user (admin)
 *   GET  /api/admin/activity               -> activity log project (admin)
 *   GET  /api/admin/export/readings        -> export readings CSV (admin)
 *   GET  /api/flush                        -> trigger manual flush+purge (X-API-Key)
 */

const RETENTION_DAYS = 2;          // simpan di Supabase 2 hari (sisanya hanya di CSV)
const WIB_OFFSET_MS  = 7 * 3600e3; // UTC+7
const MARKER_KEY     = "_state/last_flush.txt";
const STALE_MS = 30000;
const WEATHER_PLACE = {
  lat: -7.0903664216,
  lon: 110.3575795506,
  name: "Gunungpati, Kota Semarang",
};

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization, X-Client-Source",
};

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") return new Response(null, { headers: CORS });

    try {
      if (request.method === "POST" && url.pathname === "/api/sensor") return postSensor(request, env);

      if (request.method === "POST" && url.pathname === "/api/auth/login") return login(request, env);
      if (request.method === "POST" && url.pathname === "/api/auth/register") return register(request, env);
      if (request.method === "POST" && url.pathname === "/api/auth/refresh") return refreshToken(request, env);
      if (request.method === "POST" && url.pathname === "/api/auth/logout") return logout(request, env);
      if (request.method === "GET" && url.pathname === "/api/auth/me") {
        const auth = await requireAuth(request, env);
        return json({ user: publicUser(auth.user), role: auth.role });
      }

      if (request.method === "PATCH" && url.pathname === "/api/users/me") {
        const auth = await requireAuth(request, env);
        return updateMyProfile(request, env, auth);
      }
      if (request.method === "PUT" && url.pathname === "/api/users/me/password") {
        const auth = await requireAuth(request, env);
        return changeMyPassword(request, env, auth);
      }

      if (request.method === "GET" && url.pathname === "/api/sensor") {
        await requireAuth(request, env);
        return getLatest(env);
      }
      if (request.method === "GET" && url.pathname === "/api/history") {
        await requireAuth(request, env);
        return getHistory(url, env);
      }

      if (request.method === "GET" && url.pathname === "/api/devices") {
        await requireAuth(request, env);
        return getDevices(env);
      }

      const deviceLive = matchPath(url.pathname, /^\/api\/devices\/([^/]+)\/live$/);
      if (request.method === "GET" && deviceLive) {
        await requireAuth(request, env);
        return getDeviceLive(env, deviceLive[1]);
      }

      const deviceHistory = matchPath(url.pathname, /^\/api\/devices\/([^/]+)\/history$/);
      if (request.method === "GET" && deviceHistory) {
        await requireAuth(request, env);
        return getDeviceHistory(url, env, deviceHistory[1]);
      }

      const deviceSeries = matchPath(url.pathname, /^\/api\/devices\/([^/]+)\/series$/);
      if (request.method === "GET" && deviceSeries) {
        await requireAuth(request, env);
        return getDeviceSeries(url, env, deviceSeries[1]);
      }

      const deviceSparkline = matchPath(url.pathname, /^\/api\/devices\/([^/]+)\/sparkline$/);
      if (request.method === "GET" && deviceSparkline) {
        await requireAuth(request, env);
        return getDeviceSparkline(url, env, deviceSparkline[1]);
      }

      if (request.method === "GET" && url.pathname === "/api/thresholds") {
        await requireAuth(request, env);
        return getThresholds(env);
      }

      const thresholdDevice = matchPath(url.pathname, /^\/api\/thresholds\/([^/]+)$/);
      if (request.method === "PUT" && thresholdDevice) {
        // Dibuka untuk semua role (user dan admin)
        const auth = await requireAuth(request, env);
        return updateThreshold(request, env, thresholdDevice[1], auth);
      }

      if (request.method === "GET" && url.pathname === "/api/notifications") {
        await requireAuth(request, env);
        return getNotifications(url, env);
      }

      if (request.method === "POST" && url.pathname === "/api/devices") {
        const auth = await requireAuth(request, env);
        return addDevice(request, env, auth);
      }

      if (request.method === "GET" && url.pathname === "/api/devices/export") {
        const auth = await requireAuth(request, env);
        return exportDeviceReadings(request, url, env, auth);
      }

      if (request.method === "GET" && url.pathname === "/api/weather/current") {
        await requireAuth(request, env);
        return getWeather("current", env, request);
      }
      if (request.method === "GET" && url.pathname === "/api/weather/hourly") {
        await requireAuth(request, env);
        return getWeather("hourly", env, request);
      }
      if (request.method === "GET" && url.pathname === "/api/weather/daily") {
        await requireAuth(request, env);
        return getWeather("daily", env, request);
      }

      if (request.method === "GET" && url.pathname === "/api/admin/users") {
        await requireAuth(request, env, "admin");
        return listUsers(url, env);
      }

      if (request.method === "POST" && url.pathname === "/api/admin/users") {
        const auth = await requireAuth(request, env, "admin");
        return createUser(request, env, auth);
      }

      const adminUser = matchPath(url.pathname, /^\/api\/admin\/users\/([^/]+)$/);
      if (request.method === "PATCH" && adminUser) {
        const auth = await requireAuth(request, env, "admin");
        return updateUser(request, env, adminUser[1], auth);
      }
      if (request.method === "DELETE" && adminUser) {
        const auth = await requireAuth(request, env, "admin");
        return deleteUser(request, env, adminUser[1], auth);
      }

      if (request.method === "GET" && url.pathname === "/api/admin/activity") {
        await requireAuth(request, env, "admin");
        return listActivity(url, env);
      }

      if (request.method === "GET" && url.pathname === "/api/admin/export/readings") {
        const auth = await requireAuth(request, env, "admin");
        return exportReadings(request, url, env, auth);
      }

      if (request.method === "GET" && url.pathname === "/api/flush") {
        if (request.headers.get("X-API-Key") !== env.DEVICE_API_KEY) {
          await logActivity(env, {
            request,
            actor_type: "device",
            action: "device.api_key_invalid",
            target_type: "archive",
            source: "worker",
            severity: "warning",
          });
          return json({ error: "Unauthorized" }, 401);
        }
        const f = await flushToCSV(env);
        const p = await purgeOld(env);
        await logActivity(env, {
          request,
          actor_type: "system",
          action: "sensor.flush_manual",
          target_type: "archive",
          source: "worker",
          severity: f?.error || p?.error ? "warning" : "info",
          metadata: { flush: f, purge: p },
        });
        return json({ flush: f, purge: p });
      }

      return new Response("Not Found", { status: 404, headers: CORS });
    } catch (err) {
      if (err instanceof ApiError) return json({ error: err.message }, err.status);
      return json({ error: "Internal Server Error" }, 500);
    }
  },

  // Dijalankan otomatis oleh Cron Trigger (lihat wrangler.toml)
  async scheduled(event, env, ctx) {
    ctx.waitUntil((async () => {
      const f = await flushToCSV(env);
      const p = await purgeOld(env);
      console.log("cron:", JSON.stringify({ f, p }));
    })());
  },
};

// ─── AUTH ────────────────────────────────────────────────────────────
// Endpoint daftar di header (referensi)
// POST /api/auth/register         -> daftar akun mandiri
// PATCH /api/users/me             -> edit profil sendiri
// PUT /api/users/me/password      -> ganti password sendiri
// GET  /api/notifications         -> riwayat notifikasi peringatan
// POST /api/devices               -> tambah sensor/kolam baru
// GET  /api/devices/export        -> export data sensor ke CSV
async function login(request, env) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_ANON_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const email = String(body.email || "").trim();
  const password = String(body.password || "");
  if (!email || !password) return json({ error: "Email dan password wajib diisi" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: env.SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ email, password }),
  });

  const data = await res.json();
  if (!res.ok) {
    await logActivity(env, {
      request,
      actor_type: "user",
      actor_email: email,
      action: "auth.login_failed",
      target_type: "auth",
      source: "worker",
      severity: "warning",
      metadata: { detail: data.error_description || data.msg || data.error || null },
    });
    return json({ error: "Login gagal", detail: data.error_description || data.msg || data.error }, 401);
  }

  const role = getUserRole(data.user);
  await logActivity(env, {
    request,
    actor: { user: data.user, role },
    action: "auth.login_success",
    target_type: "auth",
    source: clientSource(request) || (role === "admin" ? "web_dashboard" : "mobile_app"),
    severity: "info",
  });

  return json({
    token: data.access_token,
    refresh_token: data.refresh_token,
    expires_in: data.expires_in,
    user: publicUser(data.user),
    role,
  });
}

async function register(request, env) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_ANON_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const email = String(body.email || "").trim();
  const password = String(body.password || "");
  if (!email) return json({ error: "Email wajib diisi" }, 400);
  if (!password || password.length < 6) return json({ error: "Password minimal 6 karakter" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/signup`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: env.SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ email, password }),
  });

  const data = await res.json();
  if (!res.ok) {
    return json({ error: "Registrasi gagal", detail: data.error_description || data.msg || data.error }, 400);
  }

  await logActivity(env, {
    request,
    actor_type: "user",
    actor_email: email,
    action: "auth.register",
    target_type: "auth",
    source: "mobile_app",
    severity: "info",
  });

  return json({ success: true, message: "Registrasi berhasil. Silakan cek email untuk konfirmasi." }, 201);
}

async function updateMyProfile(request, env, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const payload = {};
  const meta = {};
  if (body.email !== undefined) payload.email = String(body.email).trim();
  if (body.full_name !== undefined) meta.full_name = String(body.full_name).trim();
  if (body.phone !== undefined) meta.phone = String(body.phone).trim();
  if (Object.keys(meta).length) payload.user_metadata = meta;

  if (!Object.keys(payload).length) return json({ error: "Tidak ada data yang diubah" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users/${encodeURIComponent(auth.user.id)}`, {
    method: "PUT",
    headers: {
      ...adminAuthHeaders(env),
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const data = await checkedJson(res, "Gagal mengubah profil");
  await logActivity(env, {
    request,
    actor: auth,
    action: "user.profile_update",
    target_type: "user",
    target_id: auth.user.id,
    source: "mobile_app",
    severity: "info",
    metadata: { changed_fields: Object.keys(payload) },
  });

  return json({ success: true, user: publicUser(data) });
}

async function changeMyPassword(request, env, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const password = String(body.password || "");
  if (!password || password.length < 6) return json({ error: "Password baru minimal 6 karakter" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users/${encodeURIComponent(auth.user.id)}`, {
    method: "PUT",
    headers: {
      ...adminAuthHeaders(env),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ password }),
  });

  await checkedJson(res, "Gagal mengganti password");
  await logActivity(env, {
    request,
    actor: auth,
    action: "user.password_change",
    target_type: "user",
    target_id: auth.user.id,
    source: "mobile_app",
    severity: "info",
  });

  return json({ success: true, message: "Password berhasil diubah" });
}

async function refreshToken(request, env) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_ANON_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const refresh_token = String(body.refresh_token || "");
  if (!refresh_token) return json({ error: "refresh_token wajib diisi" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: env.SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({ refresh_token }),
  });

  const data = await res.json();
  if (!res.ok) {
    await logActivity(env, {
      request,
      actor_type: "user",
      action: "auth.refresh_failed",
      target_type: "auth",
      source: "worker",
      severity: "warning",
      metadata: { detail: data.error_description || data.msg || data.error || null },
    });
    return json({ error: "Refresh gagal", detail: data.error_description || data.msg || data.error }, 401);
  }

  return json({
    token: data.access_token,
    refresh_token: data.refresh_token,
    expires_in: data.expires_in,
    user: publicUser(data.user),
    role: getUserRole(data.user),
  });
}

async function logout(request, env) {
  const token = bearerToken(request);
  if (!token) return json({ success: true });

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/logout`, {
    method: "POST",
    headers: {
      apikey: env.SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
    },
  });

  if (!res.ok) return json({ error: "Logout gagal" }, 502);
  return json({ success: true });
}

// ─── ADMIN USERS ─────────────────────────────────────────────────────
async function listUsers(url, env) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  const page = clampInt(url.searchParams.get("page"), 1, 10000, 1);
  const perPage = clampInt(url.searchParams.get("per_page"), 1, 100, 50);
  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users?page=${page}&per_page=${perPage}`, {
    headers: adminAuthHeaders(env),
  });
  const data = await checkedJson(res, "Gagal membaca daftar user");
  const users = Array.isArray(data) ? data : data.users || [];

  return json({
    users: users.map(adminUserView),
    page,
    per_page: perPage,
    total: Number(res.headers.get("x-total-count")) || data.total || users.length,
  });
}

async function createUser(request, env, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const email = String(body.email || "").trim();
  const password = String(body.password || "");
  const role = normalizeRole(body.role);
  const emailConfirm = body.email_confirm !== false;

  if (!email) return json({ error: "Email wajib diisi" }, 400);
  if (password && password.length < 6) return json({ error: "Password minimal 6 karakter" }, 400);

  const payload = {
    email,
    email_confirm: emailConfirm,
    app_metadata: { role },
  };
  if (password) payload.password = password;

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users`, {
    method: "POST",
    headers: {
      ...adminAuthHeaders(env),
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const data = await checkedJson(res, "Gagal membuat user");
  const created = adminUserView(data);
  await logActivity(env, {
    request,
    actor: auth,
    action: "admin.user_create",
    target_type: "user",
    target_id: created.id,
    source: "web_dashboard",
    severity: "info",
    metadata: { email: created.email, role: created.role },
  });
  return json(created, 201);
}

async function updateUser(request, env, userId, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const payload = {};
  if (body.email !== undefined) payload.email = String(body.email).trim();
  if (body.password !== undefined && body.password !== "") {
    const password = String(body.password);
    if (password.length < 6) return json({ error: "Password minimal 6 karakter" }, 400);
    payload.password = password;
  }
  if (body.role !== undefined) payload.app_metadata = { role: normalizeRole(body.role) };
  if (body.banned_until !== undefined) payload.banned_until = body.banned_until || null;

  if (!Object.keys(payload).length) return json({ error: "Tidak ada data yang diubah" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users/${encodeURIComponent(userId)}`, {
    method: "PUT",
    headers: {
      ...adminAuthHeaders(env),
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  const data = await checkedJson(res, "Gagal mengubah user");
  const updated = adminUserView(data);
  await logActivity(env, {
    request,
    actor: auth,
    action: "admin.user_update",
    target_type: "user",
    target_id: userId,
    source: "web_dashboard",
    severity: "info",
    metadata: {
      email: updated.email,
      changed_fields: Object.keys(payload),
      role: updated.role,
      banned: Boolean(updated.banned_until),
    },
  });
  return json(updated);
}

async function deleteUser(request, env, userId, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);
  if (userId === auth.user.id) return json({ error: "Tidak bisa menghapus akun sendiri" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/admin/users/${encodeURIComponent(userId)}`, {
    method: "DELETE",
    headers: adminAuthHeaders(env),
  });

  if (!res.ok) await checkedJson(res, "Gagal menghapus user");
  await logActivity(env, {
    request,
    actor: auth,
    action: "admin.user_delete",
    target_type: "user",
    target_id: userId,
    source: "web_dashboard",
    severity: "warning",
  });
  return json({ success: true });
}

async function listActivity(url, env) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  const limit = clampInt(url.searchParams.get("limit"), 1, 200, 100);
  const severity = url.searchParams.get("severity");
  const source = url.searchParams.get("source");
  const action = url.searchParams.get("action");

  let q = `select=*&order=created_at.desc&limit=${limit}`;
  if (severity) q += `&severity=eq.${encodeURIComponent(severity)}`;
  if (source) q += `&source=eq.${encodeURIComponent(source)}`;
  if (action) q += `&action=eq.${encodeURIComponent(action)}`;

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/activity_logs?${q}`, { headers: readHeaders(env) });
  return json(await checkedJson(res, "Gagal membaca Activity Log"));
}

async function exportReadings(request, url, env, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  const device = url.searchParams.get("device");
  const from = url.searchParams.get("from");
  const to = url.searchParams.get("to");
  if (!device || !from || !to) return json({ error: "Parameter device, from, dan to wajib diisi" }, 400);
  assertDevice(device);

  const fromTime = Date.parse(from);
  const toTime = Date.parse(to);
  if (!Number.isFinite(fromTime) || !Number.isFinite(toTime)) return json({ error: "Format tanggal tidak valid" }, 400);
  if (fromTime > toTime) return json({ error: "Tanggal awal tidak boleh melewati tanggal akhir" }, 400);

  const maxRangeMs = 24 * 3600e3;
  if (toTime - fromTime > maxRangeMs) return json({ error: "Export dari Supabase dibatasi maksimal 1 hari" }, 400);

  const rows = [];
  const pageSize = 10000;
  const maxRows = 100000;
  let cursor = from;

  while (rows.length < maxRows) {
    const op = rows.length ? "gt" : "gte";
    const q = `select=created_at,device,temperature,ph` +
      `&device=eq.${encodeURIComponent(device)}` +
      `&created_at=${op}.${encodeURIComponent(cursor)}` +
      `&created_at=lte.${encodeURIComponent(to)}` +
      `&order=created_at.asc&limit=${pageSize}`;
    const res = await fetch(`${env.SUPABASE_URL}/rest/v1/readings?${q}`, { headers: readHeaders(env) });
    const page = await checkedJson(res, "Gagal export data");
    rows.push(...page);
    if (page.length < pageSize) break;
    cursor = page[page.length - 1].created_at;
  }

  if (rows.length >= maxRows) {
    return json({ error: "Data export terlalu besar. Pilih rentang tanggal yang lebih kecil." }, 413);
  }

  const csv = toCsv(rows);
  await logActivity(env, {
    request,
    actor: auth,
    action: "admin.export_readings",
    target_type: "readings",
    target_id: device,
    source: "web_dashboard",
    severity: "info",
    metadata: { device, from, to, rows: rows.length },
  });

  return new Response(csv, {
    status: 200,
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="sensor-${device}-${new Date(fromTime).toISOString().slice(0, 10)}.csv"`,
      ...CORS,
    },
  });
}

async function requireAuth(request, env, role = null) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_ANON_KEY"]);

  const token = bearerToken(request);
  if (!token) throw new ApiError("Unauthorized", 401);

  const res = await fetch(`${env.SUPABASE_URL}/auth/v1/user`, {
    headers: {
      apikey: env.SUPABASE_ANON_KEY,
      Authorization: `Bearer ${token}`,
    },
  });

  if (!res.ok) throw new ApiError("Unauthorized", 401);
  const user = await res.json();
  const userRole = getUserRole(user);
  if (role && userRole !== role) throw new ApiError("Forbidden", 403);
  return { user, role: userRole };
}

function adminAuthHeaders(env) {
  return {
    apikey: env.SUPABASE_SERVICE_KEY,
    Authorization: `Bearer ${env.SUPABASE_SERVICE_KEY}`,
  };
}

function bearerToken(request) {
  const value = request.headers.get("Authorization") || "";
  const match = value.match(/^Bearer\s+(.+)$/i);
  return match ? match[1] : null;
}

function normalizeRole(role) {
  return role === "admin" ? "admin" : "user";
}

function getUserRole(user) {
  return user?.app_metadata?.role === "admin" ? "admin" : "user";
}

function publicUser(u) {
  if (!u) return null;
  return {
    id: u.id,
    email: u.email,
    created_at: u.created_at,
    updated_at: u.updated_at,
    user_metadata: u.user_metadata || u.raw_user_meta_data || {},
  };
}

function adminUserView(user) {
  return {
    id: user.id,
    email: user.email,
    role: getUserRole(user),
    created_at: user.created_at,
    last_sign_in_at: user.last_sign_in_at || null,
    email_confirmed_at: user.email_confirmed_at || null,
    banned_until: user.banned_until || null,
  };
}

// ─── POST /api/sensor (batch atau tunggal) ───────────────────────────
async function postSensor(request, env) {
  if (request.headers.get("X-API-Key") !== env.DEVICE_API_KEY) {
    await logActivity(env, {
      request,
      actor_type: "device",
      action: "device.api_key_invalid",
      target_type: "readings",
      source: "esp32",
      severity: "warning",
    });
    return json({ error: "Unauthorized" }, 401);
  }

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  let rows;
  if (Array.isArray(body.readings)) {
    // Batch: {device, readings:[{t, temperature, ph}, ...]}
    const device = body.device || "unknown";
    rows = body.readings.map(r => ({
      temperature: r.temperature === undefined ? null : r.temperature,
      ph: r.ph,
      device,
      created_at: r.t,   // timestamp ISO dari ESP (NTP)
    }));
  } else {
    // Tunggal (kompatibilitas lama)
    if (body.ph === undefined) return json({ error: "Missing ph" }, 400);
    rows = [{
      temperature: body.temperature === undefined ? null : body.temperature,
      ph: body.ph,
      device: body.device || "unknown",
    }];
  }

  if (!rows.length) return json({ error: "No readings" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/readings`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      apikey: env.SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${env.SUPABASE_SERVICE_KEY}`,
      Prefer: "return=minimal",
    },
    body: JSON.stringify(rows),  // array -> bulk insert
  });

  if (!res.ok) {
    const detail = await res.text();
    await logActivity(env, {
      request,
      actor_type: "device",
      actor_id: rows[0]?.device || null,
      action: "sensor.insert_failed",
      target_type: "readings",
      target_id: rows[0]?.device || null,
      source: "esp32",
      severity: "error",
      metadata: { detail, rows: rows.length },
    });
    return json({ error: "Supabase insert failed", detail }, 502);
  }
  return json({ success: true, inserted: rows.length }, 201);
}

// ─── GET /api/devices (dinamis dari tabel thresholds) ────────────────
async function getDevices(env) {
  // Ambil daftar device dari tabel thresholds (tidak hardcode)
  const threshRes = await fetch(`${env.SUPABASE_URL}/rest/v1/thresholds?select=*&order=device.asc`, { headers: readHeaders(env) });
  const thresholdRows = await checkedJson(threshRes, "Gagal membaca threshold");
  const devices = thresholdRows.map(r => r.device);
  const thresholds = Object.fromEntries(thresholdRows.map((r) => [r.device, r]));

  if (!devices.length) return json([]);

  // Ambil data terbaru setiap device secara paralel
  const readingFetches = devices.map(device =>
    fetch(`${env.SUPABASE_URL}/rest/v1/readings?select=*&device=eq.${encodeURIComponent(device)}&order=created_at.desc&limit=1`, { headers: readHeaders(env) })
  );
  const readingResults = await Promise.all(readingFetches);

  const latest = {};
  for (let i = 0; i < devices.length; i++) {
    const device = devices[i];
    const readingRows = await checkedJson(readingResults[i], `Gagal membaca data perangkat ${device}`);
    if (readingRows.length > 0) {
      latest[device] = readingRows[0];
    }
  }

  return json(devices.map((device) => deviceSummary(device, latest[device], thresholds[device])));
}

// ─── POST /api/devices (tambah kolam/sensor baru) ────────────────────
async function addDevice(request, env, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const device = String(body.device || "").trim().toLowerCase();
  if (!device || !/^esp-\d+$/.test(device)) return json({ error: "Format device tidak valid. Gunakan format: esp-01, esp-05, dll." }, 400);

  // Cek apakah device sudah terdaftar
  const checkRes = await fetch(`${env.SUPABASE_URL}/rest/v1/thresholds?device=eq.${encodeURIComponent(device)}&select=device`, { headers: readHeaders(env) });
  const existing = await checkedJson(checkRes, "Gagal memeriksa device");
  if (existing.length > 0) return json({ error: `Device '${device}' sudah terdaftar` }, 409);

  const label = body.label || deviceLabel(device);
  const defaultThreshold = {
    device,
    label,
    ph_min: body.ph_min ?? 6.5,
    ph_max: body.ph_max ?? 8.5,
    temp_min: body.temp_min ?? 25.0,
    temp_max: body.temp_max ?? 32.0,
  };

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/thresholds`, {
    method: "POST",
    headers: {
      ...readHeaders(env),
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify(defaultThreshold),
  });

  const created = await checkedJson(res, "Gagal menambahkan device");
  await logActivity(env, {
    request,
    actor: auth,
    action: "user.device_add",
    target_type: "device",
    target_id: device,
    source: "mobile_app",
    severity: "info",
    metadata: { device, label },
  });

  return json(created[0] || defaultThreshold, 201);
}

async function getDeviceLive(env, device) {
  assertDevice(device);
  const res = await fetch(
    `${env.SUPABASE_URL}/rest/v1/readings?select=*&device=eq.${encodeURIComponent(device)}&order=created_at.desc&limit=1`,
    { headers: readHeaders(env) }
  );
  const rows = await checkedJson(res, "Gagal membaca data live");
  if (!rows.length) return json({ device, status: "offline", reading: null }, 404);
  return json({ device, status: staleStatus(rows[0]), reading: rows[0] });
}

async function getDeviceHistory(url, env, device) {
  assertDevice(device);
  url.searchParams.set("device", device);
  return getHistory(url, env);
}

async function getDeviceSeries(url, env, device) {
  assertDevice(device);
  const bucket = url.searchParams.get("bucket") || "hour";
  const from = url.searchParams.get("from");
  const to = url.searchParams.get("to");
  const allowed = new Set(["minute", "hour", "day", "month", "year"]);

  if (!allowed.has(bucket)) return json({ error: "Bucket tidak valid" }, 400);
  if (!from || !to) return json({ error: "Parameter from dan to wajib diisi" }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/rpc/get_series`, {
    method: "POST",
    headers: {
      ...readHeaders(env),
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      p_device: device,
      p_bucket: bucket,
      p_from: from,
      p_to: to,
    }),
  });

  return json(await checkedJson(res, "Gagal membaca data grafik"));
}

async function getDeviceSparkline(url, env, device) {
  assertDevice(device);
  const limit = clampInt(url.searchParams.get("limit"), 1, 300, 60);
  const res = await fetch(
    `${env.SUPABASE_URL}/rest/v1/readings?select=created_at,temperature,ph&device=eq.${encodeURIComponent(device)}&order=created_at.desc&limit=${limit}`,
    { headers: readHeaders(env) }
  );
  const rows = await checkedJson(res, "Gagal membaca sparkline");
  return json(rows.reverse());
}

async function getThresholds(env) {
  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/thresholds?select=*&order=device.asc`, { headers: readHeaders(env) });
  return json(await checkedJson(res, "Gagal membaca threshold"));
}

async function updateThreshold(request, env, device, auth) {
  await assertDevice(device, env);

  let body;
  try { body = await request.json(); }
  catch { return json({ error: "Invalid JSON" }, 400); }

  const payload = {};
  for (const key of ["ph_min", "ph_max", "temp_min", "temp_max"]) {
    if (body[key] !== undefined) {
      const value = Number(body[key]);
      if (!Number.isFinite(value)) return json({ error: `${key} harus berupa angka` }, 400);
      payload[key] = value;
    }
  }

  if (!Object.keys(payload).length) return json({ error: "Tidak ada threshold yang diubah" }, 400);
  const validation = validateThreshold(payload);
  if (validation) return json({ error: validation }, 400);

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/thresholds?device=eq.${encodeURIComponent(device)}`, {
    method: "PATCH",
    headers: {
      ...readHeaders(env),
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify(payload),
  });

  const rows = await checkedJson(res, "Gagal mengubah threshold");
  const updated = rows[0] || { device, ...payload };
  await logActivity(env, {
    request,
    actor: auth,
    action: "user.threshold_update",
    target_type: "threshold",
    target_id: device,
    source: clientSource(request) || "mobile_app",
    severity: "info",
    metadata: updated,
  });
  return json(updated);
}

// ─── GET /api/notifications ──────────────────────────────────────────
async function getNotifications(url, env) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  const limit = clampInt(url.searchParams.get("limit"), 1, 100, 50);
  const device = url.searchParams.get("device");

  let q = `select=*&order=created_at.desc&limit=${limit}`;
  // Ambil hanya log dengan severity warning atau danger (notifikasi peringatan)
  q += `&severity=in.(warning,danger,error)`;
  if (device) q += `&target_id=eq.${encodeURIComponent(device)}`;

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/activity_logs?${q}`, { headers: readHeaders(env) });
  const rows = await checkedJson(res, "Gagal membaca notifikasi");
  return json(rows);
}

// ─── GET /api/devices/export (export CSV untuk user) ─────────────────
async function exportDeviceReadings(request, url, env, auth) {
  requireEnv(env, ["SUPABASE_URL", "SUPABASE_SERVICE_KEY"]);

  const device = url.searchParams.get("device");
  const from = url.searchParams.get("from");
  const to = url.searchParams.get("to");
  if (!device || !from || !to) return json({ error: "Parameter device, from, dan to wajib diisi" }, 400);
  await assertDevice(device, env);

  const fromTime = Date.parse(from);
  const toTime = Date.parse(to);
  if (!Number.isFinite(fromTime) || !Number.isFinite(toTime)) return json({ error: "Format tanggal tidak valid" }, 400);
  if (fromTime > toTime) return json({ error: "Tanggal awal tidak boleh melewati tanggal akhir" }, 400);

  // Batasi export maksimal 7 hari
  const maxRangeMs = 7 * 24 * 3600e3;
  if (toTime - fromTime > maxRangeMs) return json({ error: "Export dibatasi maksimal 7 hari" }, 400);

  const q = `select=created_at,device,temperature,ph` +
    `&device=eq.${encodeURIComponent(device)}` +
    `&created_at=gte.${encodeURIComponent(from)}` +
    `&created_at=lte.${encodeURIComponent(to)}` +
    `&order=created_at.asc&limit=10000`;

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/readings?${q}`, { headers: readHeaders(env) });
  const rows = await checkedJson(res, "Gagal export data");

  const csv = toCsv(rows);
  await logActivity(env, {
    request,
    actor: auth,
    action: "user.export_readings",
    target_type: "readings",
    target_id: device,
    source: "mobile_app",
    severity: "info",
    metadata: { device, from, to, rows: rows.length },
  });

  const label = deviceLabel(device);
  const dateStr = new Date(fromTime).toISOString().slice(0, 10);
  return new Response(csv, {
    status: 200,
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="${label.replace(/\s/g, "_")}-${dateStr}.csv"`,
      ...CORS,
    },
  });
}

function validateThreshold(payload) {
  const required = ["ph_min", "ph_max", "temp_min", "temp_max"];
  for (const key of required) {
    if (!Number.isFinite(payload[key])) return `${key} wajib berupa angka`;
  }
  if (payload.ph_min < 0 || payload.ph_max > 14) return "Rentang pH harus berada di 0 sampai 14";
  if (payload.ph_min >= payload.ph_max) return "pH minimum harus lebih kecil dari pH maksimum";
  if (payload.temp_min < -10 || payload.temp_max > 80) return "Rentang suhu harus berada di -10 sampai 80°C";
  if (payload.temp_min >= payload.temp_max) return "Suhu minimum harus lebih kecil dari suhu maksimum";
  return null;
}

// ─── GET /api/sensor (terbaru) ───────────────────────────────────────
async function getLatest(env) {
  const res = await fetch(
    `${env.SUPABASE_URL}/rest/v1/readings?select=*&order=created_at.desc&limit=1`,
    { headers: readHeaders(env) }
  );
  const data = await res.json();
  if (!data.length) return json({ error: "No data yet" }, 404);
  return json(data[0]);
}

// ─── GET /api/history?device=eq.esp-01&limit=50&from=&to= ────────────
async function getHistory(url, env) {
  const limit = clampInt(url.searchParams.get("limit"), 1, 500, 50);
  const device = url.searchParams.get("device");
  const from = url.searchParams.get("from");
  const to   = url.searchParams.get("to");

  let q = `select=*&order=created_at.desc&limit=${limit}`;
  if (device) {
    const cleanDevice = device.replace(/^eq\./, "");
    assertDevice(cleanDevice);
    q += `&device=eq.${encodeURIComponent(cleanDevice)}`;
  }
  if (from)   q += `&created_at=gte.${encodeURIComponent(from)}`;
  if (to)     q += `&created_at=lte.${encodeURIComponent(to)}`;

  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/readings?${q}`, { headers: readHeaders(env) });
  return json(await checkedJson(res, "Gagal membaca riwayat"));
}

// ─── WEATHER API ─────────────────────────────────────────────────────
async function getWeather(kind, env, request) {
  const data = await fetchWeather(env, request);
  if (kind === "current") return json({ place: WEATHER_PLACE, current: data.current });

  if (kind === "hourly") {
    const hourly = data.hourly;
    return json({
      place: WEATHER_PLACE,
      hourly: hourly.time.map((time, i) => ({
        time,
        temperature_2m: hourly.temperature_2m[i],
        relative_humidity_2m: hourly.relative_humidity_2m[i],
        apparent_temperature: hourly.apparent_temperature[i],
        precipitation: hourly.precipitation[i],
        precipitation_probability: hourly.precipitation_probability[i],
        weather_code: hourly.weather_code[i],
        wind_speed_10m: hourly.wind_speed_10m[i],
        surface_pressure: hourly.surface_pressure[i],
      })),
    });
  }

  const daily = data.daily;
  return json({
    place: WEATHER_PLACE,
    daily: daily.time.map((time, i) => ({
      time,
      weather_code: daily.weather_code[i],
      temperature_2m_max: daily.temperature_2m_max[i],
      temperature_2m_min: daily.temperature_2m_min[i],
      precipitation_probability_max: daily.precipitation_probability_max[i],
    })),
  });
}

async function fetchWeather(env, request) {
  const url = `https://api.open-meteo.com/v1/forecast?latitude=${WEATHER_PLACE.lat}&longitude=${WEATHER_PLACE.lon}` +
    `&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,surface_pressure` +
    `&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,precipitation_probability,weather_code,wind_speed_10m,surface_pressure` +
    `&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max` +
    `&timezone=Asia%2FJakarta&forecast_days=7`;

  let res;
  try {
    res = await fetch(url, {
      headers: {
        "User-Agent": "sensor-monitor-worker/1.0",
      },
    });
  } catch (err) {
    await logActivity(env, {
      request,
      actor_type: "system",
      action: "weather.fetch_failed",
      target_type: "weather",
      source: "weather_api",
      severity: "warning",
      metadata: { detail: err?.message || String(err) },
    });
    throw new ApiError("Gagal memuat data cuaca", 502);
  }

  if (!res.ok) {
    await logActivity(env, {
      request,
      actor_type: "system",
      action: "weather.fetch_failed",
      target_type: "weather",
      source: "weather_api",
      severity: "warning",
      metadata: { status: res.status },
    });
    throw new ApiError("Gagal memuat data cuaca", 502);
  }
  return res.json();
}

// ─── CRON: flush baris baru -> CSV harian di R2 ──────────────────────
async function flushToCSV(env) {
  if (!env.ARCHIVE) return { error: "R2 binding ARCHIVE belum diset" };

  // marker = created_at terakhir yang sudah diarsipkan
  const markerObj = await env.ARCHIVE.get(MARKER_KEY);
  const since = markerObj ? (await markerObj.text()).trim() : "1970-01-01T00:00:00Z";

  // ambil baris baru (urut naik), batasi agar ringan
  const q = `select=created_at,device,temperature,ph` +
            `&created_at=gt.${encodeURIComponent(since)}` +
            `&order=created_at.asc&limit=20000`;
  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/readings?${q}`, { headers: readHeaders(env) });
  if (!res.ok) return { error: "query gagal", detail: await res.text() };
  const rows = await res.json();
  if (!rows.length) return { flushed: 0 };

  // kelompokkan per tanggal WIB -> baris CSV
  const groups = {};
  for (const r of rows) {
    const date = wibDate(r.created_at);
    const line = `${r.created_at},${r.device},${r.temperature ?? ""},${r.ph ?? ""}\n`;
    (groups[date] ||= []).push(line);
  }

  // tambahkan ke file harian (read-modify-write)
  for (const [date, lines] of Object.entries(groups)) {
    const key = `data_${date}.csv`;
    const existing = await env.ARCHIVE.get(key);
    let content = existing ? await existing.text() : "timestamp,device,temperature,ph\n";
    content += lines.join("");
    await env.ARCHIVE.put(key, content);
  }

  const last = rows[rows.length - 1].created_at;
  await env.ARCHIVE.put(MARKER_KEY, last);
  return { flushed: rows.length, until: last, files: Object.keys(groups) };
}

// ─── CRON: hapus baris >RETENTION_DAYS hari (yang SUDAH diarsipkan) ───
async function purgeOld(env) {
  const markerObj = env.ARCHIVE ? await env.ARCHIVE.get(MARKER_KEY) : null;
  const marker = markerObj ? (await markerObj.text()).trim() : null;
  if (!marker) return { purged: "skip (belum ada arsip)" };

  const twoDaysAgo = new Date(Date.now() - RETENTION_DAYS * 86400e3).toISOString();
  // cutoff = lebih lama antara (2 hari lalu) & marker -> jangan hapus yang belum diarsip
  const cutoff = marker < twoDaysAgo ? marker : twoDaysAgo;

  const res = await fetch(
    `${env.SUPABASE_URL}/rest/v1/readings?created_at=lt.${encodeURIComponent(cutoff)}`,
    { method: "DELETE", headers: readHeaders(env) }
  );
  return { purged_before: cutoff, ok: res.ok };
}

// ─── Helpers ─────────────────────────────────────────────────────────
function wibDate(iso) {
  const wib = new Date(new Date(iso).getTime() + WIB_OFFSET_MS);
  return wib.toISOString().slice(0, 10);  // YYYY-MM-DD (tanggal WIB)
}

async function logActivity(env, entry) {
  if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_KEY) return;

  const actor = entry.actor ? activityActor(entry.actor) : {};
  const row = {
    actor_type: entry.actor_type || actor.actor_type || "system",
    actor_id: entry.actor_id ?? actor.actor_id ?? null,
    actor_email: entry.actor_email ?? actor.actor_email ?? null,
    action: entry.action,
    target_type: entry.target_type || null,
    target_id: entry.target_id || null,
    source: entry.source || "worker",
    severity: entry.severity || "info",
    ip_address: clientIp(entry.request),
    user_agent: entry.request?.headers.get("User-Agent") || null,
    metadata: entry.metadata || {},
  };

  try {
    const res = await fetch(`${env.SUPABASE_URL}/rest/v1/activity_logs`, {
      method: "POST",
      headers: {
        ...readHeaders(env),
        "Content-Type": "application/json",
        Prefer: "return=minimal",
      },
      body: JSON.stringify(row),
    });
    if (!res.ok) console.warn("activity log failed:", await res.text());
  } catch (err) {
    console.warn("activity log failed:", err?.message || err);
  }
}

function activityActor(auth) {
  const user = auth?.user || auth;
  const role = auth?.role || getUserRole(user);
  return {
    actor_type: role === "admin" ? "admin" : "user",
    actor_id: user?.id || null,
    actor_email: user?.email || null,
  };
}

function clientIp(request) {
  return request?.headers.get("CF-Connecting-IP") ||
    request?.headers.get("X-Forwarded-For")?.split(",")[0]?.trim() ||
    null;
}

function clientSource(request) {
  const source = request?.headers.get("X-Client-Source");
  return source && /^[a-z0-9_-]+$/i.test(source) ? source : null;
}

function readHeaders(env) {
  return {
    apikey: env.SUPABASE_SERVICE_KEY,
    Authorization: `Bearer ${env.SUPABASE_SERVICE_KEY}`,
  };
}

async function checkedJson(res, message) {
  if (res.ok) return res.json();
  let detail;
  try { detail = await res.text(); }
  catch { detail = ""; }
  throw new ApiError(detail ? `${message}: ${detail}` : message, 502);
}

function deviceSummary(device, reading, threshold) {
  const status = reading ? staleStatus(reading) : "offline";
  return {
    device,
    label: deviceLabel(device),
    status: status === "online" && threshold && isOutOfRange(reading, threshold) ? "danger" : status,
    reading: reading || null,
    threshold: threshold || null,
  };
}

function staleStatus(reading) {
  if (!reading?.created_at) return "offline";
  return Date.now() - new Date(reading.created_at).getTime() > STALE_MS ? "offline" : "online";
}

function isOutOfRange(reading, threshold) {
  const temp = reading.temperature;
  const ph = reading.ph;
  return (
    (temp != null && (temp < threshold.temp_min || temp > threshold.temp_max)) ||
    (ph != null && (ph < threshold.ph_min || ph > threshold.ph_max))
  );
}

function toCsv(rows) {
  const header = "created_at,device,temperature,ph\n";
  const body = rows.map((row) => [
    row.created_at,
    row.device,
    row.temperature ?? "",
    row.ph ?? "",
  ].map(csvCell).join(",")).join("\n");
  return body ? `${header}${body}\n` : header;
}

function csvCell(value) {
  const text = String(value);
  if (!/[",\n]/.test(text)) return text;
  return `"${text.replace(/"/g, '""')}"`;
}

function deviceLabel(device) {
  const n = device.match(/\d+$/)?.[0];
  return n ? `Kolam ${Number(n)}` : device;
}

async function assertDevice(device, env) {
  // Validasi device secara dinamis dari database
  if (env) {
    const res = await fetch(`${env.SUPABASE_URL}/rest/v1/thresholds?device=eq.${encodeURIComponent(device)}&select=device`, { headers: readHeaders(env) });
    if (res.ok) {
      const rows = await res.json();
      if (!rows.length) throw new ApiError("Device tidak valid", 400);
      return;
    }
  }
  // Fallback validasi format
  if (!/^esp-\d+$/.test(device)) throw new ApiError("Device tidak valid", 400);
}

function clampInt(value, min, max, fallback) {
  const n = Number.parseInt(value, 10);
  if (!Number.isFinite(n)) return fallback;
  return Math.min(max, Math.max(min, n));
}

function matchPath(pathname, regex) {
  const match = pathname.match(regex);
  return match ? match.map((part, i) => (i === 0 ? part : decodeURIComponent(part))) : null;
}

function requireEnv(env, names) {
  for (const name of names) {
    if (!env[name]) throw new ApiError(`Secret ${name} belum diset`, 500);
  }
}

class ApiError extends Error {
  constructor(message, status = 500) {
    super(message);
    this.status = status;
  }
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json", ...CORS },
  });
}
