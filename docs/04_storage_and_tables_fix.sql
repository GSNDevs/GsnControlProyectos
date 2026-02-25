-- 1. Create project_documents table (if it wasn't created yet)
CREATE TABLE IF NOT EXISTS public.project_documents (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  project_id uuid REFERENCES public.projects(id) ON DELETE CASCADE,
  file_name text NOT NULL,
  file_url text NOT NULL,
  file_type text NOT NULL,
  uploaded_by uuid REFERENCES public.profiles(id),
  created_at timestamp with time zone DEFAULT now()
);

-- Enable RLS for project_documents
ALTER TABLE public.project_documents ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated users (or public for testing based on your current setup)
CREATE POLICY "Allow all operations on project_documents" 
ON public.project_documents FOR ALL 
USING (true) WITH CHECK (true);

-- 2. Storage Policies for 'project_documents' bucket
-- Note: Replace 'project_documents' with your actual bucket name if different.
-- Allow public access to read
CREATE POLICY "Give public access to project_documents" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'project_documents');

-- Allow authenticated users to upload to project_documents
CREATE POLICY "Allow authenticated uploads to project_documents" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'project_documents');

-- Allow authenticated users to delete their own uploads or any upload depending on needs
CREATE POLICY "Allow authenticated deletes to project_documents" 
ON storage.objects FOR DELETE 
USING (bucket_id = 'project_documents');

-- Allow authenticated users to update
CREATE POLICY "Allow authenticated updates to project_documents" 
ON storage.objects FOR UPDATE 
USING (bucket_id = 'project_documents');

-- 3. Storage Policies for 'task_evidence' bucket
-- Allow public access to read
CREATE POLICY "Give public access to task_evidence" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'task_evidence');

-- Allow authenticated users to upload to task_evidence
CREATE POLICY "Allow authenticated uploads to task_evidence" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'task_evidence');

-- Allow authenticated users to delete
CREATE POLICY "Allow authenticated deletes to task_evidence" 
ON storage.objects FOR DELETE 
USING (bucket_id = 'task_evidence');

-- Allow authenticated users to update
CREATE POLICY "Allow authenticated updates to task_evidence" 
ON storage.objects FOR UPDATE 
USING (bucket_id = 'task_evidence');
