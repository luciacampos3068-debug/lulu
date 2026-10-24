import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

Deno.serve(async request => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return Response.json({ error: "Method not allowed." }, { status: 405, headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return Response.json({ error: "Server Supabase environment is not configured." }, {
      status: 500,
      headers: corsHeaders
    });
  }

  const authorization = request.headers.get("Authorization");
  if (!authorization) {
    return Response.json({ error: "Authentication required." }, { status: 401, headers: corsHeaders });
  }

  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false }
  });
  const { data: { user }, error: userError } = await callerClient.auth.getUser();
  if (userError || !user) {
    return Response.json({ error: "Invalid session." }, { status: 401, headers: corsHeaders });
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false }
  });
  const { data: callerProfile, error: profileError } = await adminClient
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (profileError || callerProfile?.role !== "admin") {
    return Response.json({ error: "Administrator access required." }, { status: 403, headers: corsHeaders });
  }

  let body: { email?: unknown };
  try {
    body = await request.json();
  } catch {
    return Response.json({ error: "Invalid JSON body." }, { status: 400, headers: corsHeaders });
  }
  const email = typeof body.email === "string" ? body.email.trim().toLowerCase() : "";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return Response.json({ error: "A valid email is required." }, { status: 400, headers: corsHeaders });
  }

  const { error: inviteError } = await adminClient.auth.admin.inviteUserByEmail(email);
  if (inviteError) {
    return Response.json({ error: inviteError.message }, { status: 400, headers: corsHeaders });
  }
  return Response.json({ invited: true }, { status: 200, headers: corsHeaders });
});
