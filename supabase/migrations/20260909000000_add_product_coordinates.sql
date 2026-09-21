-- Añadir soporte numérico para geolocalización tradicional en la tabla de productos
ALTER TABLE public.products 
ADD COLUMN latitude double precision NULL,
ADD COLUMN longitude double precision NULL;

-- Comentario explicativo de las columnas para documentación interna
COMMENT ON COLUMN public.products.latitude IS 'Latitud de geolocalizacion del articulo';
COMMENT ON COLUMN public.products.longitude IS 'Longitud de geolocalizacion del articulo';
