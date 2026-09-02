// Calvary Portal: sync a profile to/from GHL contacts.
// Call shape: POST { profile_id: uuid }
//
// CONFIRMED WORKING end-to-end (tested 2 Sep 2026): a real test profile was
// created, synced to GHL via net.http_post from inside Postgres (pg_net),
// returned 200 OK with a real GHL contact ID, write-back to profiles
// confirmed by direct query, then the test contact and test user were both
// deleted to leave no clutter in the live CRM or database. GHL_API_KEY
// secret is set as a Supabase project secret.
//
// verify_jwt is false deliberately, matching create-checkout/stripe-webhook
// in this same project -- this function is meant to be called server-to-server
// (a database trigger via pg_net, or an internal service call), not directly
// from a signed-in user's browser session.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const GHL_BASE = "https://services.leadconnectorhq.com";
const GHL_LOCATION_ID = "ufTeOHywYxLPaG9TDWPG";

Deno.serve(async (req: Request) => {
  try {
    const { profile_id } = await req.json();
    if (!profile_id) {
      return new Response(JSON.stringify({ error: "profile_id required" }), { status: 400 });
    }

    const ghlKey = Deno.env.get("GHL_API_KEY");
    if (!ghlKey) {
      return new Response(
        JSON.stringify({ error: "GHL_API_KEY secret not set. Add it in Supabase project settings before this function can run." }),
        { status: 500 }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: profile, error: profileErr } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", profile_id)
      .single();

    if (profileErr || !profile) {
      return new Response(JSON.stringify({ error: "profile not found", detail: profileErr }), { status: 404 });
    }

    const ghlHeaders = {
      "Authorization": `Bearer ${ghlKey}`,
      "Version": "2021-07-28",
      "Content-Type": "application/json",
    };

    let ghlContactId = profile.ghl_contact_id as string | null;

    if (!ghlContactId && profile.email) {
      const dupRes = await fetch(
        `${GHL_BASE}/contacts/search/duplicate?locationId=${GHL_LOCATION_ID}&email=${encodeURIComponent(profile.email)}`,
        { headers: ghlHeaders }
      );
      if (dupRes.ok) {
        const dupData = await dupRes.json();
        if (dupData?.contact?.id) {
          ghlContactId = dupData.contact.id;
        }
      } else {
        const errText = await dupRes.text();
        return new Response(JSON.stringify({ error: "GHL duplicate-check failed", status: dupRes.status, detail: errText }), { status: 502 });
      }
    }

    if (ghlContactId) {
      await fetch(`${GHL_BASE}/contacts/${ghlContactId}`, {
        method: "PUT",
        headers: ghlHeaders,
        body: JSON.stringify({
          name: profile.full_name ?? undefined,
          email: profile.email ?? undefined,
          phone: profile.phone ?? undefined,
        }),
      });
    } else {
      const createRes = await fetch(`${GHL_BASE}/contacts/`, {
        method: "POST",
        headers: ghlHeaders,
        body: JSON.stringify({
          locationId: GHL_LOCATION_ID,
          name: profile.full_name ?? undefined,
          email: profile.email ?? undefined,
          phone: profile.phone ?? undefined,
        }),
      });
      if (createRes.ok) {
        const createData = await createRes.json();
        ghlContactId = createData?.contact?.id ?? null;
      } else {
        const errText = await createRes.text();
        return new Response(JSON.stringify({ error: "GHL create-contact failed", status: createRes.status, detail: errText }), { status: 502 });
      }
    }

    await supabase
      .from("profiles")
      .update({ ghl_contact_id: ghlContactId, last_synced_at: new Date().toISOString() })
      .eq("id", profile_id);

    return new Response(JSON.stringify({ ok: true, ghl_contact_id: ghlContactId }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
