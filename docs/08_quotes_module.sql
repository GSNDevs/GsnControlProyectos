-- ==========================================
-- 08_quotes_module.sql
-- Adds the quotes tracking system.
-- ==========================================

-- 1. Create Quotes Table
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
  documents_urls jsonb, -- Array of strings for evidence/files
  created_at timestamp with time zone default now()
);

-- 2. RLS Policies for Quotes
alter table public.quotes enable row level security;

-- Admins/Staff can view all quotes
create policy "Staff/Admin view all quotes"
  on public.quotes for select
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- Clients can view their own quotes
create policy "Clients view own quotes"
  on public.quotes for select
  using ( client_id = auth.uid() );

-- Clients can insert quotes (requests)
create policy "Clients can insert quotes"
  on public.quotes for insert
  with check ( client_id = auth.uid() );

-- Admins/Staff can update quotes (if we later add status tracking like 'responded')
create policy "Staff/Admin can update quotes"
  on public.quotes for update
  using (
    exists (
      select 1 from public.profiles
      where profiles.id = auth.uid() and profiles.role in ('admin', 'staff')
    )
  );

-- 3. Storage Bucket Configuration (Run in Dashboard, or here if using Supabase CLI with storage extensions configured)
-- For demonstration/local CLI (Requires Storage schema enabled):
INSERT INTO storage.buckets (id, name, public) 
VALUES ('quotes_documents', 'quotes_documents', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies for 'quotes_documents' bucket
create policy "Public access to quotes documents"
  on storage.objects for select
  using ( bucket_id = 'quotes_documents' );

create policy "Authenticated users can upload quote docs"
  on storage.objects for insert
  with check (
    bucket_id = 'quotes_documents' 
    and auth.role() = 'authenticated'
  );

create policy "Authenticated users can delete own quote docs"
  on storage.objects for delete
  using (
    bucket_id = 'quotes_documents'
    and auth.role() = 'authenticated'
  );
