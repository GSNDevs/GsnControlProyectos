-- ==============================================================================
-- MIGRACIÓN: GESTIÓN DOCUMENTAL (ARCHIVOS DEL PROYECTO)
-- ==============================================================================
-- Este script crea la tabla `project_documents` que permitirá almacenar
-- la metadata de los archivos y documentos subidos al proyecto.
--
-- NOTA: Ejecutar este script directamente en el editor SQL de Supabase.

-- 1. Crear tabla para documentos de proyecto
CREATE TABLE IF NOT EXISTS public.project_documents (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  project_id uuid REFERENCES public.projects(id) ON DELETE CASCADE NOT NULL,
  file_name text NOT NULL,
  file_url text NOT NULL,
  file_type text NOT NULL, -- Ej: 'pdf', 'image', 'word'
  uploaded_by uuid REFERENCES public.profiles(id),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Políticas de seguridad (Opcional, si RLS está activo)
-- ALTER TABLE public.project_documents ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Permitir lectura autenticada" ON public.project_documents FOR SELECT USING (auth.role() = 'authenticated');
-- CREATE POLICY "Permitir escritura autenticada" ON public.project_documents FOR INSERT WITH CHECK (auth.role() = 'authenticated');
-- CREATE POLICY "Permitir borrado autenticado" ON public.project_documents FOR DELETE USING (auth.role() = 'authenticated');
