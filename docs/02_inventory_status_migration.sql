-- ==============================================================================
-- MIGRACIÓN: AÑADIR ESTADO 'assigned' EN INVENTARIO DE PROYECTO
-- ==============================================================================
-- Este script altera la tabla `project_inventory` para actualizar la restricción
-- de comprobación (CHECK constraint) de la columna `status`, permitiendo el 
-- valor 'assigned' además de los existentes ('reserved', 'installed', 'returned').
--
-- NOTA: Ejecutar este script directamente en el editor SQL de Supabase.

-- 1. Eliminar la restricción de comprobación existente
ALTER TABLE public.project_inventory 
DROP CONSTRAINT IF EXISTS project_inventory_status_check;

-- 2. Añadir la nueva restricción permitiendo el estado 'assigned'
ALTER TABLE public.project_inventory
ADD CONSTRAINT project_inventory_status_check 
CHECK (status IN ('reserved', 'installed', 'returned', 'assigned'));
