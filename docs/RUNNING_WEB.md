# Ejecución y Despliegue Web

## Requisitos Previos (Prerequisites)
- Tener instalado el Flutter SDK (versión estable recomendada).
- Tener instalado Google Chrome.
- Ejecutar `flutter doctor` para verificar que todo esté en orden.
- Crear un archivo `.env` en la raíz del proyecto con tus credenciales de Supabase (ver paso siguiente).

## Configuración de Entorno (.env)

El proyecto utiliza `flutter_dotenv` para manejar las credenciales. Crea un archivo llamado `.env` en la raíz (`/`) con el siguiente contenido:

```env
SUPABASE_URL=tu_url_de_supabase
SUPABASE_ANON_KEY=tu_anon_key_de_supabase
```

**Nota:** Este archivo está en `.gitignore` y no se debe subir al repositorio.

## Desarrollo Local (Development)

Para ejecutar la aplicación en modo debug utilizando Chrome:

```bash
flutter run -d chrome
```

Si deseas especificar un puerto o renderizador (html vs canvaskit):

```bash
flutter run -d chrome --web-renderer html
```

## Build de Producción (Production Build)

Para generar los archivos estáticos optimizados para despliegue:

```bash
flutter build web
```

Los archivos resultantes se encontrarán en `build/web/`.

## Solución de Problemas (Troubleshooting)

Si encuentras errores de compilación o dependencias:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## Notas Adicionales
- Asegúrate de tener las credenciales de Supabase configuradas en `lib/main.dart` correctamente.
- Si estás probando la autenticación localmente, verifica que los usuarios de prueba existan en tu base de datos o dashboard.
