// Calvary Portal: shared auth module. Every page includes this and calls
// CalvaryAuth.init() to know who's signed in and what they can see.
// One source of truth for session + profile + roles, so no page has to
// re-implement auth checking on its own.

const CalvaryAuth = (function () {
  const SUPABASE_URL = "https://pfycvgbrsbecznkcikwt.supabase.co";
  const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBmeWN2Z2Jyc2JlY3pua2Npa3d0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzNzY1NDgsImV4cCI6MjA5MDk1MjU0OH0.xw_DSmC0brKC7K9H-rxNG0HKKDi4I-dNSEoZKERvHcQ";

  let client = null;
  function getClient() {
    if (!client) {
      client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    }
    return client;
  }

  // Returns { session, profile } -- profile is null if signed out.
  async function init() {
    const sb = getClient();
    const { data: { session } } = await sb.auth.getSession();
    if (!session) return { session: null, profile: null };

    const { data: profile } = await sb
      .from("profiles")
      .select("*")
      .eq("id", session.user.id)
      .single();

    return { session, profile };
  }

  function hasRole(profile, role) {
    return !!(profile && profile.roles && profile.roles.includes(role));
  }

  function hasAnyRole(profile, roles) {
    return roles.some((r) => hasRole(profile, r));
  }

  async function signInWithPassword(email, password) {
    return getClient().auth.signInWithPassword({ email, password });
  }

  async function signUpWithPassword(email, password, fullName) {
    return getClient().auth.signUp({
      email,
      password,
      options: { data: { full_name: fullName } },
    });
  }

  async function signInWithMagicLink(email) {
    return getClient().auth.signInWithOtp({
      email,
      options: { emailRedirectTo: window.location.origin + "/index.html" },
    });
  }

  async function signOut() {
    await getClient().auth.signOut();
    window.location.href = "index.html";
  }

  // Call at the top of any page that requires sign-in. Redirects to login
  // if there's no session; redirects to index if signed in but missing a
  // required role. Returns { session, profile } if the guard passes.
  async function requireAuth(requiredRoles) {
    const { session, profile } = await init();
    if (!session) {
      window.location.href = "login.html?next=" + encodeURIComponent(window.location.pathname);
      return null;
    }
    if (requiredRoles && requiredRoles.length && !hasAnyRole(profile, requiredRoles)) {
      window.location.href = "index.html?denied=1";
      return null;
    }
    return { session, profile };
  }

  return {
    getClient,
    init,
    hasRole,
    hasAnyRole,
    signInWithPassword,
    signUpWithPassword,
    signInWithMagicLink,
    signOut,
    requireAuth,
  };
})();
