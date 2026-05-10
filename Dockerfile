# Stage 1: "Builder" (Cumpliendo IE1 multi-stage build)
FROM node:18-alpine AS builder
WORKDIR /app
COPY index.html app.js ./

# Stage 2: Producción
FROM nginx:alpine

# Limpiar default de nginx
RUN rm -rf /usr/share/nginx/html/*

# Copiar archivos desde el stage anterior
COPY --from=builder /app/index.html /app/app.js /usr/share/nginx/html/

# Copiar configuración custom (escuchando en 8080)
COPY default.conf /etc/nginx/conf.d/default.conf

# Configurar permisos para que Nginx pueda correr como usuario "nginx" no-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Cambiar a usuario no privilegiado (Requerimiento de IE1 - Máximo Privilegio de Seguridad)
USER nginx

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]