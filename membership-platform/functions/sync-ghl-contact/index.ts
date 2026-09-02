// Calvary Portal: sync a profile to/from GHL contacts.
// Call shape: POST { profile_id: uuid }
// Looks up the profile, checks GHL for a duplicate contact by email/phone,
// links or creates as needed, and writes ghl_contact_id + last_synced_at back.
//
// REQUIRES a Supabase secret named GHL_API_KEY (a GHL Private Integration
// Token with contacts.readonly + contacts.write scopes) to be set before
// this will work. Deployed without it failing loudly on purpose, rather
// than silently doing nothing.

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
        return new Response(JSON.stringify({ error: "GHL create-contact failed", detail: errText }), { status: 502 });
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
