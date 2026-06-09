select
  id as unit_id,
  slug,
  name_ar,
  login_key,
  login_key || 'admin' as admin_username,
  login_key || '123'   as admin_password,
  login_key || 'usr1'  as user1_username,
  login_key || '456'   as user1_password,
  login_key || 'usr2'  as user2_username,
  login_key || '456'   as user2_password
from core.org_units
where coalesce(is_active, true) = true
  and nullif(trim(login_key), '') is not null
order by login_key;
