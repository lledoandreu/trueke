-- 1. Habilitar la extensión PostGIS en el esquema de extensiones si no está activa
CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;

-- 2. Añadir la columna de geografía nativa Point (SRID 4326)
ALTER TABLE public.products 
ADD COLUMN geo_location extensions.geography(Point, 4326);

-- 3. Crear el índice espacial GIST para búsquedas ultra rápidas
CREATE INDEX IF NOT EXISTS products_geo_location_idx 
ON public.products USING gist (geo_location);

-- 4. Crear la función del Trigger para autogenerar geo_location al insertar/actualizar
CREATE OR REPLACE FUNCTION public.tr_update_products_geo_location()
RETURNS trigger AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.geo_location := extensions.st_makepoint(NEW.longitude, NEW.latitude)::extensions.geography;
  ELSE
    NEW.geo_location := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Asignar el Trigger a la tabla de productos
CREATE OR REPLACE TRIGGER tr_products_geo_location_sync
BEFORE INSERT OR UPDATE ON public.products
FOR EACH ROW
EXECUTE FUNCTION public.tr_update_products_geo_location();

-- 6. Actualizar retroactivamente las filas existentes que ya tengan coordenadas
UPDATE public.products 
SET geo_location = extensions.st_makepoint(longitude, latitude)::extensions.geography
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- 7. Crear la función RPC nativa optimizada que consumirá Trueke
CREATE OR REPLACE FUNCTION public.search_products_by_radius(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision,
  search_query text DEFAULT NULL,
  search_category text DEFAULT NULL
)
RETURNS SETOF public.products AS $$
BEGIN
  RETURN QUERY
  SELECT p.*
  FROM public.products p
  WHERE 
    -- Filtrado espacial por radio nativo (st_dwithin usa metros)
    extensions.st_dwithin(
      p.geo_location,
      extensions.st_makepoint(user_lng, user_lat)::extensions.geography,
      radius_km * 1000
    )
    -- Filtrado por Query de texto opcional (case insensitive)
    AND (search_query IS NULL OR search_query = '' OR p.title ILIKE '%' || search_query || '%' OR p.description ILIKE '%' || search_query || '%')
    -- Filtrado por Categoría opcional
    AND (search_category IS NULL OR search_category = '' OR p.category = search_category)
  ORDER BY 
    extensions.st_distance(
      p.geo_location,
      extensions.st_makepoint(user_lng, user_lat)::extensions.geography
    ) ASC,
    p.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
