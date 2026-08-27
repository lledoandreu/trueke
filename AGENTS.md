# Trueke — reglas para agentes de desarrollo

## Objetivo

Trueke es una plataforma Flutter de compraventa e intercambio de productos,
con autenticación, catálogo, favoritos, chat, perfiles, ofertas de intercambio
y backend Supabase.

Los agentes deben priorizar siempre estabilidad, funcionalidad y continuidad
del proyecto.

## Entorno

- Flutter: stable
- Dart: 3.12.2 o compatible con `pubspec.yaml`
- Backend: Supabase
- Gestión de estado: Riverpod
- Plataforma principal de desarrollo: macOS
- Repositorio: GitHub

## Reglas obligatorias

1. No modificar secretos, claves privadas ni credenciales.
2. No eliminar migraciones existentes de Supabase.
3. No modificar datos remotos directamente si no es necesario.
4. Antes de cambiar arquitectura, revisar primero el código existente.
5. Mantener las funcionalidades existentes.
6. No introducir dependencias innecesarias.
7. Usar `dart format` después de modificar Dart.
8. Ejecutar siempre:

   flutter analyze
   flutter test

9. No considerar terminado un bloque si `flutter analyze` falla.
10. No considerar terminado un bloque si los tests fallan.
11. Revisar `git diff` antes de realizar un commit.
12. No utilizar `git push --force`.
13. No reescribir historial remoto.
14. No crear commits con código que no haya sido validado.
15. Mantener el repositorio limpio al finalizar un bloque de trabajo.
16. Las migraciones nuevas deben tener nombres cronológicos y descriptivos.
17. Después de crear una migración, comprobar su estado con:

   supabase migration list

18. Si una operación automática falla, detenerse y explicar el error en lugar
    de continuar a ciegas.

## Desarrollo autónomo

Un agente puede:

- inspeccionar el proyecto;
- modificar código;
- crear tests;
- ejecutar formatter;
- ejecutar analyzer;
- ejecutar tests;
- revisar Git;
- preparar commits;
- revisar GitHub Actions.

Antes de hacer `push`, debe comprobar:

- `flutter analyze`
- `flutter test`
- `git diff`
- `git status`

El push automático queda sujeto a las reglas del entorno/agente y no debe
forzarse.

## Criterio de finalización

Un bloque de trabajo se considera correcto cuando:

- la funcionalidad solicitada está implementada;
- no se han roto funcionalidades existentes;
- `dart format` ha sido ejecutado;
- `flutter analyze` termina sin errores;
- `flutter test` termina correctamente;
- las migraciones necesarias están sincronizadas;
- el diff ha sido revisado;
- Git está limpio;
- y el commit está correctamente identificado.

## Prioridad

Prioridad 1: funcionamiento.

Prioridad 2: estabilidad.

Prioridad 3: seguridad.

Prioridad 4: calidad del código.

Prioridad 5: mejoras estéticas/refactorizaciones.

No realizar refactorizaciones grandes cuando no sean necesarias para la tarea.
