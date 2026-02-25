-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. PROFILES (Extends auth.users)
create table public.profiles (
  id uuid references auth.users not null primary key,
  email text,
  full_name text,
  avatar_url text,
  role text check (role in ('admin', 'staff', 'client', 'public')) default 'staff',
  rut text,
  company_name text,
  fantasy_name text,
  address text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Trigger to handle new user creation automatically
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (
    new.id, 
    new.email, 
    new.raw_user_meta_data->>'full_name', 
    coalesce((new.raw_user_meta_data->>'role')::text, 'staff') -- User metadata role or default 'staff'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. INVENTORY CATALOG
create table public.inventory_catalog (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  sku text unique,
  category text,
  default_price numeric default 0,
  stock_count integer default 0,
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 3. PROJECTS
create table public.projects (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  client_id uuid references public.profiles(id),
  type text check (type in ('physical', 'software', 'hybrid')) not null,
  status text check (status in ('planning', 'in_progress', 'blocked', 'completed')) default 'planning',
  description text,
  
  -- Financials
  budget_total numeric default 0,
  billed_amount numeric default 0,
  pending_amount numeric default 0,
  currency text default 'CLP',
  
  -- Progress (0-100)
  progress integer default 0,
  
  is_template boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- 4. PROJECT DETAILS (Physical)
create table public.project_details_physical (
  project_id uuid references public.projects(id) on delete cascade primary key,
  address text,
  coordinates text, -- 'lat,lng'
  vehicle_id text,
  installation_notes text
);

-- 5. PROJECT DETAILS (Software)
create table public.project_details_software (
  project_id uuid references public.projects(id) on delete cascade primary key,
  repo_url text,
  prod_url text,
  staging_url text,
  tech_stack jsonb -- ['flutter', 'supabase', 'node']
);

-- 6. PROJECT INVENTORY (Pivot)
create table public.project_inventory (
  id uuid default uuid_generate_v4() primary key,
  project_id uuid references public.projects(id) on delete cascade,
  product_id uuid references public.inventory_catalog(id),
  quantity integer default 1,
  assigned_to_user_id uuid references public.profiles(id),
  status text check (status in ('reserved', 'installed', 'returned')) default 'reserved'
);

-- 7. ITERATIONS (Sprints/Phases)
create table public.iterations (
  id uuid default uuid_generate_v4() primary key,
  project_id uuid references public.projects(id) on delete cascade,
  name text not null, -- 'Sprint 1' or 'Cabling Phase'
  start_date date,
  end_date date,
  client_approval_status text check (client_approval_status in ('pending', 'approved', 'rejected')) default 'pending',
  client_approval_date timestamp with time zone,
  created_at timestamp with time zone default now()
);

-- 8. TASKS
create table public.tasks (
  id uuid default uuid_generate_v4() primary key,
  iteration_id uuid references public.iterations(id) on delete cascade,
  title text not null,
  description text,
  assigned_to jsonb, -- Array of profile IDs
  status text check (status in ('todo', 'doing', 'done')) default 'todo',
  evidence_url text, -- Photo/Screenshot
  created_at timestamp with time zone default now()
);

-- 9. AUDIT LOGS
create table public.audit_logs (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id),
  table_name text not null,
  record_id uuid,
  action text, -- 'INSERT', 'UPDATE', 'DELETE'
  old_value jsonb,
  new_value jsonb,
  timestamp timestamp with time zone default now()
);

-- 10. NOTIFICATIONS
create table public.notifications (
  id uuid default uuid_generate_v4() primary key,
  recipient_id uuid references public.profiles(id) not null,
  message text not null,
  related_project_id uuid references public.projects(id),
  read boolean default false,
  created_at timestamp with time zone default now()
);


-- ==========================================
-- RLS POLICIES
-- ==========================================

-- 1. PROFILES
alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using ( true );

create policy "Users can update own profile"
  on public.profiles for update
  using ( auth.uid() = id );

-- 2. INVENTORY CATALOG
alter table public.inventory_catalog enable row level security;

create policy "Inventory viewable by authenticated users"
  on public.inventory_catalog for select
  using ( auth.role() = 'authenticated' );

-- Split into explicit actions for better error handling and clarity
create policy "Staff/Admin can insert inventory"
  on public.inventory_catalog for insert
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Staff/Admin can update inventory"
  on public.inventory_catalog for update
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Staff/Admin can delete inventory"
  on public.inventory_catalog for delete
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- 3. PROJECTS
alter table public.projects enable row level security;

create policy "Staff/Admin view all projects"
  on public.projects for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Clients view own projects"
  on public.projects for select
  using ( client_id = auth.uid() );

create policy "Staff/Admin can insert projects"
  on public.projects for insert
  with check (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Staff/Admin can update projects"
  on public.projects for update
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- 4. PROJECT DETAILS (Physical & Software)
alter table public.project_details_physical enable row level security;
alter table public.project_details_software enable row level security;

-- Policies for Physical Details
create policy "Staff/Admin view physical details"
  on public.project_details_physical for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Clients view physical details of their projects"
  on public.project_details_physical for select
  using (
    exists (
      select 1 from public.projects
      where projects.id = project_details_physical.project_id
      and projects.client_id = auth.uid()
    )
  );

create policy "Staff/Admin manage physical details"
  on public.project_details_physical for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- Policies for Software Details
create policy "Staff/Admin view software details"
  on public.project_details_software for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Clients view software details of their projects"
  on public.project_details_software for select
  using (
    exists (
      select 1 from public.projects
      where projects.id = project_details_software.project_id
      and projects.client_id = auth.uid()
    )
  );

create policy "Staff/Admin manage software details"
  on public.project_details_software for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- 6. PROJECT INVENTORY
alter table public.project_inventory enable row level security;

create policy "Staff/Admin view project inventory"
  on public.project_inventory for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Clients view inventory of their projects"
  on public.project_inventory for select
  using (
    exists (
      select 1 from public.projects
      where projects.id = project_inventory.project_id
      and projects.client_id = auth.uid()
    )
  );

create policy "Staff/Admin manage project inventory"
  on public.project_inventory for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- 7. ITERATIONS
alter table public.iterations enable row level security;

create policy "Staff/Admin view iterations"
  on public.iterations for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Clients view iterations of their projects"
  on public.iterations for select
  using (
    exists (
      select 1 from public.projects
      where projects.id = iterations.project_id
      and projects.client_id = auth.uid()
    )
  );

create policy "Staff/Admin manage iterations"
  on public.iterations for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- Clients can approve/reject iterations (update specific columns ideally, but for now allow update if own project)
create policy "Clients can update iterations of their projects"
  on public.iterations for update
  using (
    exists (
      select 1 from public.projects
      where projects.id = iterations.project_id
      and projects.client_id = auth.uid()
    )
  );

-- 8. TASKS
alter table public.tasks enable row level security;

create policy "Staff/Admin view tasks"
  on public.tasks for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

create policy "Clients view tasks of their projects"
  on public.tasks for select
  using (
    exists (
      select 1 from public.projects
      join public.iterations on iterations.project_id = projects.id
      where iterations.id = tasks.iteration_id
      and projects.client_id = auth.uid()
    )
  );

create policy "Staff/Admin manage tasks"
  on public.tasks for all
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- 9. AUDIT LOGS
alter table public.audit_logs enable row level security;

create policy "Admins view audit logs"
  on public.audit_logs for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role = 'admin'
    )
  );

-- 10. NOTIFICATIONS
alter table public.notifications enable row level security;

create policy "Users view their own notifications"
  on public.notifications for select
  using ( recipient_id = auth.uid() );

create policy "Users can update (mark read) their own notifications"
  on public.notifications for update
  using ( recipient_id = auth.uid() );

create policy "Users can insert notifications"
  on public.notifications for insert
  with check (auth.role() = 'authenticated');

-- Enable Realtime
alter publication supabase_realtime add table public.projects;
alter publication supabase_realtime add table public.notifications;

-- ==========================================
-- DATA SEED (TEST USERS)
-- Important: Insert only if not exists to avoid errors on duplicate key
-- Password for all users will be '123456' (hash provided is a placeholder valid for some local setups or needs to be real bcrypt)
-- Note: On hosted Supabase, you might not be able to insert into auth.users directly. Use the dashboard or API to create users, then update their roles here. 
-- However, for local development (Supabase CLI), this usually works.
-- ==========================================

DO $$
DECLARE
  -- Variables for user IDs
  uid_admin1 uuid := '00000000-0000-0000-0000-000000000001';
  uid_admin2 uuid := '00000000-0000-0000-0000-000000000002';
  uid_staff1 uuid := '00000000-0000-0000-0000-000000000003';
  uid_staff2 uuid := '00000000-0000-0000-0000-000000000004';
  uid_staff3 uuid := '00000000-0000-0000-0000-000000000005';
  uid_client1 uuid := '00000000-0000-0000-0000-000000000006';
  uid_client2 uuid := '00000000-0000-0000-0000-000000000007';
  uid_client3 uuid := '00000000-0000-0000-0000-000000000008';
  uid_client4 uuid := '00000000-0000-0000-0000-000000000009';
  uid_client5 uuid := '00000000-0000-0000-0000-000000000010';
  -- bcrypt hash for '123456'
  pass_hash text := '123456'; -- This is a placeholder/example hash. Real one needed.
  -- For local dev often we can just create the user.
BEGIN
  -- Insert users into auth.users if possible (often restricted on hosted)
  -- If this fails, create users manually via dashboard with these emails.
  
  -- We will wrap in a block to ignore errors if auth.users insert fails (e.g. permission denied on hosted)
  BEGIN
    INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, role)
    VALUES 
      (uid_admin1, 'test1@test.cl', pass_hash, now(), 'authenticated'),
      (uid_admin2, 'test2@test.cl', pass_hash, now(), 'authenticated'),
      (uid_staff1, 'test3@test.cl', pass_hash, now(), 'authenticated'),
      (uid_staff2, 'test4@test.cl', pass_hash, now(), 'authenticated'),
      (uid_staff3, 'test5@test.cl', pass_hash, now(), 'authenticated'),
      (uid_client1, 'test6@test.cl', pass_hash, now(), 'authenticated'),
      (uid_client2, 'test7@test.cl', pass_hash, now(), 'authenticated'),
      (uid_client3, 'test8@test.cl', pass_hash, now(), 'authenticated'),
      (uid_client4, 'test9@test.cl', pass_hash, now(), 'authenticated'),
      (uid_client5, 'test10@test.cl', pass_hash, now(), 'authenticated')
    ON CONFLICT (id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Skipping auth.users insert (likely permission denied or already exists). Ensure users created manually.';
  END;

  -- Insert/Update public.profiles
  -- We assume if auth.users exist (either inserted above or manually), we can insert into profiles.
  
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES
    (uid_admin1, 'test1@test.cl', 'Admin User 1', 'admin'),
    (uid_admin2, 'test2@test.cl', 'Admin User 2', 'admin'),
    (uid_staff1, 'test3@test.cl', 'Staff User 1', 'staff'),
    (uid_staff2, 'test4@test.cl', 'Staff User 2', 'staff'),
    (uid_staff3, 'test5@test.cl', 'Staff User 3', 'staff'),
    (uid_client1, 'test6@test.cl', 'Client User 1', 'client'),
    (uid_client2, 'test7@test.cl', 'Client User 2', 'client'),
    (uid_client3, 'test8@test.cl', 'Client User 3', 'client'),
    (uid_client4, 'test9@test.cl', 'Client User 4', 'client'),
    (uid_client5, 'test10@test.cl', 'Client User 5', 'client')
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    full_name = EXCLUDED.full_name;

END $$;

-- ==========================================
-- 11. QUOTES MODULE
-- ==========================================

create table public.quotes (
  id uuid default uuid_generate_v4() primary key,
  client_id uuid references public.profiles(id) not null,
  service_type text check (service_type in ('Software', 'Hardware', 'Hybrid')) not null,
  title text not null,
  description text,
  phone text not null,
  email text not null,
  urgency text,
  has_current_system text,
  is_replacement text,
  documents_urls jsonb,
  created_at timestamp with time zone default now()
);

alter table public.quotes enable row level security;

create policy "Staff/Admin view all quotes" on public.quotes for select using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
  )
);

create policy "Clients view own quotes" on public.quotes for select using ( client_id = auth.uid() );

create policy "Clients can insert quotes" on public.quotes for insert with check ( client_id = auth.uid() );

create policy "Staff/Admin can update quotes" on public.quotes for update using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
  )
);


