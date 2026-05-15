# Frontend - Tienda de Perritos

Este repositorio contiene la capa de presentación (Nivel 1) de la arquitectura de tres niveles de la aplicación web "Tienda de Perritos".

## Descripción

El proyecto expone una aplicación HTML/JS servida mediante Nginx. Está diseñado para ser desplegado en una **subred pública** dentro de AWS, actuando como el único punto de contacto expuesto a Internet. 

Además de servir archivos estáticos, este nivel funciona como un **Proxy Inverso**. Todas las peticiones al backend se realizan a la misma IP pública bajo la ruta `/api/`, las cuales Nginx intercepta y redirige a la IP privada del backend (oculto en una subred privada), previniendo así errores de CORS y mejorando la seguridad.

## Archivos Principales

- `index.html`: Estructura principal de la aplicación web.
- `app.js`: Lógica de cliente, encargada de consumir la API REST del backend utilizando peticiones `fetch('/api/productos')`.
- `default.conf`: Archivo de configuración de Nginx. Contiene el bloque de *proxy inverso* (proxy_pass) apuntando a la IP privada del backend.
- `Dockerfile`: Orquesta la construcción de la imagen. Implementa buenas prácticas de seguridad y eficiencia:
  - **Multi-stage build**: Minimiza el peso de la imagen final.
  - **Ejecución No-Root**: Se configuran permisos estrictos y el servidor Nginx se ejecuta utilizando el usuario sin privilegios `nginx`.

## Flujo de Trabajo y Despliegue

1. **Desarrollo:** Realiza modificaciones en `index.html` o `app.js`.
2. **Pruebas Locales:** Puedes usar `docker-compose.yml` localmente para probar tus cambios.
3. **CI/CD:** Al hacer un `push` a la rama `deploy`, se dispara automáticamente el pipeline de GitHub Actions (`.github/workflows/main.yml`).
   - El pipeline construirá la imagen Docker.
   - Se subirá al registro de ECR en AWS.
   - Invocará el agente de Systems Manager (SSM) en la instancia EC2 para actualizar el contenedor de manera transparente y segura, sin exponer puertos SSH a internet.

> **Nota:** Este archivo `README.md` se excluye intencionalmente del pipeline de GitHub Actions y del contenedor de Docker mediante las reglas `.dockerignore` y `paths-ignore` para que los simples cambios de documentación no desencadenen despliegues en producción ni engrosen la imagen final.
