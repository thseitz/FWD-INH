
 Here’s a concrete, copy-pasteable configuration plan that’s secure and production-ready. It uses **Cognito Hosted UI + Authorization Code (PKCE)**, your **backend behind API Gateway** to exchange the code for tokens, and **httpOnly cookies** for session security.

---

# 1) Cognito: exact console settings

**User Pool → App integration → App client (create or edit):**
- **Allowed OAuth flows:** ✅ Authorization code grant  
  (❌ Implicit, ❌ Client credentials)
- **OAuth 2.0 scopes:** `openid`, `email`, `profile` (add any custom if needed)
- **Callback URLs:**  
  `https://api.example.com/auth/callback`  ← **API Gateway endpoint** that proxies to your NestJS `/auth/callback`
- **Sign-out URLs:**  
  `https://app.example.com/`  ← where users land after logout
- **Allowed origins (CORS):**  
  `https://app.example.com`
- **App client secret:** Not required when using **PKCE**.
- **Domain name:**  
  e.g., `your-pool-domain.auth.us-west-2.amazoncognito.com`

---

# 2) SPA ↔ API Gateway ↔ Backend auth routes

API Gateway proxies the same three routes to your NestJS backend:

1) **GET `/auth/login`**  
   - Same as before: generates `state`, `code_verifier`, `code_challenge`.
   - Redirects user to Cognito Hosted UI.

2) **GET `/auth/callback`**  
   - Cognito redirects here with the `code`.
   - API Gateway forwards to NestJS, which exchanges code for tokens.
   - NestJS sets cookies (see §3).
   - Redirects user back to SPA (`https://app.example.com`).

3) **POST `/auth/refresh`**  
   - SPA makes this request with cookies.
   - API Gateway forwards to NestJS, which refreshes tokens and sets new cookies.

**Optional:**  
- **`/auth/logout`** and **`/me`** still go through API Gateway to NestJS.

---

# 3) Cookie names, flags, and lifetimes

Same as before — but remember these cookies must be set by **your backend behind API Gateway**:

- `id_token` → HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=3600  
- `access_token` → HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=3600  
- `refresh_token` → HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=2592000 (~30d)

Anti-CSRF helper:
- `XSRF-TOKEN` → Secure; SameSite=Lax; not HttpOnly

> If your SPA and API Gateway are on different eTLD+1 (e.g., `app.com` vs `api.net`), use `SameSite=None; Secure`.

---

# 4) SPA behavior (unchanged)

- **Login button:** redirect to `https://api.example.com/auth/login`
- **Logout button:** redirect to `https://api.example.com/auth/logout`
- **API calls:**  
  Use `fetch` with `credentials: 'include'` and `X-XSRF-TOKEN` header.  
  API Gateway passes cookies → backend verifies tokens.

---

# 5) API Gateway configuration

- **Proxy mode**: Forward all `/auth/*` and `/api/*` to NestJS backend.  
- **Binary/media types**: Not needed for auth, but configure as usual.  
- **CORS on API Gateway**:  
  - `Access-Control-Allow-Origin: https://app.example.com`  
  - `Access-Control-Allow-Credentials: true`  
  - `Access-Control-Allow-Headers: Content-Type, X-XSRF-TOKEN`  
  - `Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS`  

API Gateway should **not** strip or modify cookies; configure it to forward headers/cookies intact.

---

# 6) Backend API security (NestJS behind API Gateway)

- Still validate the **access_token** per request:
  - Verify JWT signature using Cognito JWKS.
  - Ensure `iss`, `aud`, `token_use`, and `exp` are valid.
- If expired → trigger refresh flow once.
- Enforce **authorization** using groups/claims.

API Gateway can also use a **Cognito Authorizer** to short-circuit unauthenticated requests before they hit NestJS, but since you’re using httpOnly cookies, your NestJS backend usually handles the JWT check directly.

---

# 7) Amplify in this architecture

- Amplify still **orchestrates Hosted UI redirects**, but tokens never touch JS.  
- Amplify is only used for UX helpers, not storage.  
- All real auth and API calls go through **API Gateway** with cookies.

---

# 8) MFA / 2FA

No change: Cognito Hosted UI enforces MFA policies, Amplify surfaces challenges if needed.

---

# 9) Logout

- SPA calls `https://api.example.com/auth/logout`
- Backend clears cookies, optionally calls Cognito GlobalSignOut
- Redirects user back to SPA

---

# 10) Monitoring & ops

- Same rules: clock sync, JWKS refresh, refresh rotation, short TTLs.

---

## Quick “do/don’t” checklist (with API Gateway)

**Do**
- Configure API Gateway to **forward cookies & headers** untouched.  
- Set CORS to allow credentials from your SPA domain.  
- Keep JWT validation in NestJS (or add Cognito Authorizer if you want defense-in-depth).  
- Use httpOnly, Secure cookies.

**Don’t**
- Don’t let API Gateway strip `Set-Cookie` headers.  
- Don’t store tokens in JS.  
- Don’t bypass JWT checks in NestJS (API Gateway authorizer is optional, not sufficient alone).
