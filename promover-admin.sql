update public.profiles
set role = 'admin'
where email = 'luciacampos3068@gmail.com';

select email, role
from public.profiles
where email = 'luciacampos3068@gmail.com';
