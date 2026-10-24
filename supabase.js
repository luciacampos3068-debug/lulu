import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const hasValidConfig =
  typeof supabaseUrl === "string" &&
  typeof supabaseKey === "string" &&
  /^https:\/\/[a-z0-9-]+\.supabase\.co$/i.test(supabaseUrl) &&
  supabaseKey.length > 0;

export const supabase = hasValidConfig
  ? createClient(supabaseUrl, supabaseKey)
  : null;