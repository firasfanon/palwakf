import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const url = process.env.SUPABASE_URL ?? process.env.VITE_SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY ?? process.env.SUPABASE_ANON_KEY ?? process.env.VITE_SUPABASE_ANON_KEY;

if (!url || !key) {
  console.error('Missing SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY/SUPABASE_ANON_KEY.');
  process.exit(2);
}

const supabase = createClient(url, key, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const requiredFamilies = ['image_or_pdf', 'word_processing', 'spreadsheet', 'cad'];
const { data, error } = await supabase.rpc('rpc_document_file_type_uat_coverage_v1');

if (error) {
  console.error('RPC rpc_document_file_type_uat_coverage_v1 failed. Apply SQL 05 first.');
  console.error(error);
  process.exit(1);
}

const rows = Array.isArray(data) ? data : [];
console.table(rows.map((row) => ({
  file_family: row.file_family,
  evidence_count: row.evidence_count,
  is_closed: row.is_closed,
  fields: row.observed_fields_count,
  uncertain: row.observed_uncertain_segments_count,
  links: row.observed_candidate_links_count,
  latest_engine: row.latest_engine_profile,
})));

const missing = requiredFamilies.filter((family) => !rows.some((row) => row.file_family === family && row.is_closed === true));
if (missing.length > 0) {
  console.error(`UAT coverage is not closed for: ${missing.join(', ')}`);
  process.exit(3);
}

console.log('SQL 05 live UAT coverage is closed for all required file families.');
