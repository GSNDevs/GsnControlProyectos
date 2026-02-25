-- ==============================================================================
-- MIGRACIÓN: MÚLTIPLES RESPONSABLES POR TAREA
-- ==============================================================================
-- Este script altera la tabla `tasks` para permitir asignar a más de una
-- persona por tarea, utilizando un array JSON (jsonb) que contendrá los
-- IDs de los usuarios (profiles).
--
-- NOTA: Ejecutar este script directamente en el editor SQL de Supabase.

-- 1. Eliminar la restricción de clave foránea existente para `assigned_to`
ALTER TABLE public.tasks 
DROP CONSTRAINT IF EXISTS tasks_assigned_to_fkey;

-- 2. Cambiar el tipo de dato de uuid a jsonb, migrando los datos existentes
ALTER TABLE public.tasks
ALTER COLUMN assigned_to TYPE jsonb USING (
  CASE 
    WHEN assigned_to IS NULL THEN '[]'::jsonb 
    ELSE jsonb_build_array(assigned_to) 
  END
);
