-- Migración 07: Google Drive Integration

-- Añadir columna drive_folder_url a projects
ALTER TABLE public.projects ADD COLUMN drive_folder_url text;
