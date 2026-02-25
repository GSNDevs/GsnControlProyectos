-- Migration 06: User Management and Categories

-- 1. Create Product Categories Table
CREATE TABLE public.product_categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Note: In the Flutter code the Product model's "category" is currently a String
-- To maintain simplicity and retro-compatibility, we can let user enter names that match this table
-- Alternatively, we can add a foreign key pointing to the categories table. Let's add a proper column for future use.
ALTER TABLE public.inventory_catalog ADD COLUMN category_id UUID REFERENCES public.product_categories(id) ON DELETE SET NULL;

-- 2. Modify Profiles Table for Soft Deletes
ALTER TABLE public.profiles ADD COLUMN enabled BOOLEAN DEFAULT true NOT NULL;

-- 3. RLS Product Categories
ALTER TABLE public.product_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable Read access for authenticated users (Categories)" 
ON public.product_categories 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Enable Insert access for authenticated users (Categories)" 
ON public.product_categories 
FOR INSERT 
TO authenticated 
WITH CHECK (true);

CREATE POLICY "Enable Update access for authenticated users (Categories)" 
ON public.product_categories 
FOR UPDATE 
TO authenticated 
USING (true);

CREATE POLICY "Enable Delete access for authenticated users (Categories)" 
ON public.product_categories 
FOR DELETE 
TO authenticated 
USING (true);

-- End of migration
