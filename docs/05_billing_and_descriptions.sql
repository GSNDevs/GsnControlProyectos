-- 1. Add description to Iterations and Tasks
ALTER TABLE public.iterations 
ADD COLUMN IF NOT EXISTS description text;

ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS description text;

-- 2. Create task_documents table for multiple files
CREATE TABLE IF NOT EXISTS public.task_documents (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  task_id uuid REFERENCES public.tasks(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_url text NOT NULL,
  uploaded_by uuid REFERENCES public.profiles(id),
  created_at timestamp with time zone DEFAULT now()
);

-- Note: We already have task_evidence storage bucket and its policies. We will just use it.
ALTER TABLE public.task_documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations on task_documents" 
ON public.task_documents FOR ALL 
USING (true) WITH CHECK (true);

-- 3. Create project_payments table
CREATE TABLE IF NOT EXISTS public.project_payments (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  project_id uuid REFERENCES public.projects(id) ON DELETE CASCADE,
  amount double precision NOT NULL, 
  payment_type text NOT NULL CHECK (payment_type IN ('unico', 'suscripcion', 'adicional')),
  description text,
  payment_date timestamp with time zone DEFAULT now(),
  created_by uuid REFERENCES public.profiles(id)
);

ALTER TABLE public.project_payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all operations on project_payments" 
ON public.project_payments FOR ALL 
USING (true) WITH CHECK (true);
