# Stage 1: "Builder" (Etapa de construcción)
# Usamos una imagen ligera de Node.js basada en Alpine Linux para empaquetar los estáticos.
FROM node:18-alpine AS builder

# Establecemos /app como el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copiamos el archivo HTML y el script JS desde nuestra máquina local hacia el directorio /app del contenedor.
COPY index.html app.js ./

# Stage 2: Producción (Etapa final)
# Usamos la imagen oficial de Nginx basada en Alpine para servir los archivos por HTTP.
FROM nginx:alpine

# Limpiamos los archivos por defecto que trae Nginx en su carpeta pública.
RUN rm -rf /usr/share/nginx/html/*

# Copiamos los archivos index.html y app.js desde la etapa anterior (builder) hacia la carpeta pública de Nginx.
COPY --from=builder /app/index.html /app/app.js /usr/share/nginx/html/

# Copiamos nuestra configuración personalizada de Nginx para reemplazar la que viene por defecto.
COPY default.conf /etc/nginx/conf.d/default.conf

# Ajustamos los permisos de las carpetas y archivos críticos de Nginx para que el usuario "nginx" sea el dueño.
# Esto es necesario porque vamos a ejecutar el contenedor como un usuario sin privilegios de administrador.
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Cambiamos al usuario "nginx" (un usuario no-root) para aumentar la seguridad del contenedor.
USER nginx

# Declaramos que el contenedor escuchará peticiones en el puerto 8080 (ya que no somos root, no podemos usar el 80).
EXPOSE 8080

# Comando por defecto para iniciar el servidor Nginx en primer plano y mantener el contenedor vivo.
CMD ["nginx", "-g", "daemon off;"]