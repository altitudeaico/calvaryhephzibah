// bible-proxy — fetches scripture from API.Bible without ever exposing the
// API key to the browser. The key lives in the API_BIBLE_KEY function secret
// (Dashboard -> Edge Functions -> Secrets). NEVER commit the key to this file.
//
// Actions:
//   GET ?action=versions
//     -> { versions: [{ code, bibleId, name }] }   (whatever this key can access)
//   GET ?action=passage&bibleId=..&book=1%20John&chapter=3&start=16&end=18&version=NIV
//     -> { verses: [{ book, chapter, verse, text, version }] }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const API = "https://rest.api.bible/v1";
const KEY = Deno.env.get("API_BIBLE_KEY") ?? "";

const BOOK_CODES: Record<string, string> = {
  "Genesis":"GEN","Exodus":"EXO","Leviticus":"LEV","Numbers":"NUM","Deuteronomy":"DEU",
  "Joshua":"JOS","Judges":"JDG","Ruth":"RUT","1 Samuel":"1SA","2 Samuel":"2SA",
  "1 Kings":"1KI","2 Kings":"2KI","1 Chronicles":"1CH","2 Chronicles":"2CH",
  "Ezra":"EZR","Nehemiah":"NEH","Esther":"EST","Job":"JOB","Psalms":"PSA",
  "Proverbs":"PRO","Ecclesiastes":"ECC","Song of Solomon":"SNG","Isaiah":"ISA",
  "Jeremiah":"JER","Lamentations":"LAM","Ezekiel":"EZK","Daniel":"DAN","Hosea":"HOS",
  "Joel":"JOL","Amos":"AMO","Obadiah":"OBA","Jonah":"JON","Micah":"MIC","Nahum":"NAM",
  "Habakkuk":"HAB","Zephaniah":"ZEP","Haggai":"HAG","Zechariah":"ZEC","Malachi":"MAL",
  "Matthew":"MAT","Mark":"MRK","Luke":"LUK","John":"JHN","Acts":"ACT","Romans":"ROM",
  "1 Corinthians":"1CO","2 Corinthians":"2CO","Galatians":"GAL","Ephesians":"EPH",
  "Philippians":"PHP","Colossians":"COL","1 Thessalonians":"1TH","2 Thessalonians":"2TH",
  "1 Timothy":"1TI","2 Timothy":"2TI","Titus":"TIT","Philemon":"PHM","Hebrews":"HEB",
  "James":"JAS","1 Peter":"1PE","2 Peter":"2PE","1 John":"1JN","2 John":"2JN",
  "3 John":"3JN","Jude":"JUD","Revelation":"REV"
};

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { ...CORS, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (!KEY) return json({ error: "API_BIBLE_KEY secret not set" }, 500);

  const url = new URL(req.url);
  const action = url.searchParams.get("action") ?? "";

  try {
    if (action === "versions") {
      const r = await fetch(`${API}/bibles?language=eng&include-full-details=false`, {
        headers: { "api-key": KEY },
      });
      if (!r.ok) return json({ error: `api.bible ${r.status}` }, 502);
      const d = await r.json();
      const versions = (d.data ?? []).map((b: any) => ({
        code: (b.abbreviationLocal || b.abbreviation || "").toUpperCase(),
        bibleId: b.id,
        name: b.name,
      }));
      return json({ versions });
    }

    if (action === "passage") {
      const bibleId = url.searchParams.get("bibleId") ?? "";
      const book = url.searchParams.get("book") ?? "";
      const chapter = parseInt(url.searchParams.get("chapter") ?? "0");
      const start = parseInt(url.searchParams.get("start") ?? "0");
      const end = parseInt(url.searchParams.get("end") ?? String(start));
      const version = url.searchParams.get("version") ?? "";
      const code = BOOK_CODES[book];
      if (!bibleId || !code || !chapter || !start) return json({ error: "bad params" }, 400);
      if (end - start > 60) return json({ error: "range too large" }, 400);

      const pid = `${code}.${chapter}.${start}-${code}.${chapter}.${end}`;
      const qs = "content-type=text&include-notes=false&include-titles=false" +
                 "&include-chapter-numbers=false&include-verse-numbers=true&include-verse-spans=false";
      const r = await fetch(`${API}/bibles/${bibleId}/passages/${pid}?${qs}`, {
        headers: { "api-key": KEY },
      });
      if (!r.ok) return json({ error: `api.bible ${r.status}` }, 502);
      const d = await r.json();
      const content: string = d?.data?.content ?? "";

      // FUMS usage beacon (publisher fair-use compliance) — fired server-side.
      const fums = d?.meta?.fumsToken;
      if (fums) fetch(`https://fums.api.bible/f3?t=${fums}`).catch(() => {});

      // content-type=text with verse numbers reads like "[16] For God so ..."
      const verses: { book: string; chapter: number; verse: number; text: string; version: string }[] = [];
      const parts = content.split(/\[(\d+)\]/);
      for (let i = 1; i < parts.length; i += 2) {
        const n = parseInt(parts[i]);
        const text = (parts[i + 1] ?? "").replace(/\s+/g, " ").trim();
        if (n && text) verses.push({ book, chapter, verse: n, text, version });
      }
      if (!verses.length && content.trim()) {
        verses.push({ book, chapter, verse: start, text: content.replace(/\s+/g, " ").trim(), version });
      }
      return json({ verses });
    }

    return json({ error: "unknown action" }, 400);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
