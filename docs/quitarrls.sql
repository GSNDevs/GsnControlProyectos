-- ==============================================================================
-- SCRIPT PARA ELIMINAR Y DESACTIVAR RLS (ROW LEVEL SECURITY)
-- ==============================================================================
-- Este script realiza dos acciones para cada tabla:
-- 1. DROP POLICY: Elimina las políticas específicas existentes.
-- 2. DISABLE PROW LEVEL SECURITY: Desactiva la comprobación de seguridad a nivel de fila.
--
-- ADVERTENCIA: Esto permite que CUALQUIER usuario con acceso a la base de datos (anon/authenticated)
-- pueda leer/escribir si tiene los permisos GRANT básicos (que por defecto en Supabase 'public' suele tener).
-- El control de acceso dependerá exclusivamente de la lógica de la aplicación (Frontend/Backend).
-- ==============================================================================

-- 1. PROFILES
alter table public.profiles disable row level security;
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;

-- 2. INVENTORY CATALOG
alter table public.inventory_catalog disable row level security;
drop policy if exists "Inventory viewable by authenticated users" on public.inventory_catalog;
drop policy if exists "Staff/Admin can manage inventory" on public.inventory_catalog;
drop policy if exists "Staff/Admin can insert inventory" on public.inventory_catalog;
drop policy if exists "Staff/Admin can update inventory" on public.inventory_catalog;
drop policy if exists "Staff/Admin can delete inventory" on public.inventory_catalog;

-- 3. PROJECTS
alter table public.projects disable row level security;
drop policy if exists "Staff/Admin view all projects" on public.projects;
drop policy if exists "Clients view own projects" on public.projects;
drop policy if exists "Staff/Admin can insert projects" on public.projects;
drop policy if exists "Staff/Admin can update projects" on public.projects;

-- 4. PROJECT DETAILS (Physical & Software)
alter table public.project_details_physical disable row level security;
drop policy if exists "Staff/Admin view physical details" on public.project_details_physical;
drop policy if exists "Clients view physical details of their projects" on public.project_details_physical;
drop policy if exists "Staff/Admin manage physical details" on public.project_details_physical;

alter table public.project_details_software disable row level security;
drop policy if exists "Staff/Admin view software details" on public.project_details_software;
drop policy if exists "Clients view software details of their projects" on public.project_details_software;
drop policy if exists "Staff/Admin manage software details" on public.project_details_software;

-- 6. PROJECT INVENTORY
alter table public.project_inventory disable row level security;
drop policy if exists "Staff/Admin view project inventory" on public.project_inventory;
drop policy if exists "Clients view inventory of their projects" on public.project_inventory;
drop policy if exists "Staff/Admin manage project inventory" on public.project_inventory;

-- 7. ITERATIONS
alter table public.iterations disable row level security;
drop policy if exists "Staff/Admin view iterations" on public.iterations;
drop policy if exists "Clients view iterations of their projects" on public.iterations;
drop policy if exists "Staff/Admin manage iterations" on public.iterations;
drop policy if exists "Clients can update iterations of their projects" on public.iterations;

-- 8. TASKS
alter table public.tasks disable row level security;
drop policy if exists "Staff/Admin view tasks" on public.tasks;
drop policy if exists "Clients view tasks of their projects" on public.tasks;
drop policy if exists "Staff/Admin manage tasks" on public.tasks;

-- 9. AUDIT LOGS
alter table public.audit_logs disable row level security;
drop policy if exists "Admins view audit logs" on public.audit_logs;

-- 10. NOTIFICATIONS
alter table public.notifications disable row level security;
drop policy if exists "Users view their own notifications" on public.notifications;
drop policy if exists "Users can update (mark read) their own notifications" on public.notifications;

-- Confirmación
DO $$
BEGIN
  RAISE NOTICE 'Todas las políticas RLS han sido eliminadas y la seguridad desactivada en las tablas públicas.';
END $$;
