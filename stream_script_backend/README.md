# Node.js Supabase Auth Backend

## Setup

1. Copy `.env.example` to `.env` and fill in your Supabase credentials.
2. Install dependencies:
   ```bash
   npm install express body-parser dotenv @supabase/supabase-js
   ```
3. Start the server:
   ```bash
   node src/app.js
   ```

## API Endpoints

- `POST /auth/signup` — `{ email, password }`
- `POST /auth/signin` — `{ email, password }`
- `POST /auth/signout` — no body required

## Project Structure

```
src/
  app.js                # Express app entry point
  supabaseClient.js     # Supabase client setup
  controllers/
    authController.js   # Auth logic
  routes/
    authRoutes.js       # Auth routes
.env.example            # Example environment config
```
