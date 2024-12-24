services:
  postiz:
    image: ghcr.io/gitroomhq/postiz-app:latest
    container_name: postiz
    restart: always
    environment:
      # You must change these. `yourServerAddress` is what your web browser uses.
      MAIN_URL: "https://socialjarvis-nladbvrr.b4a.run"
      FRONTEND_URL: "https://socialjarvis-nladbvrr.b4a.run"
      NEXT_PUBLIC_BACKEND_URL: "https://socialjarvis-nladbvrr.b4a.run/api"
      JWT_SECRET: "jnasg98iangnarlgmfearag"
 
      # These defaults are probably fine, but if you change your user/password, update it in the 
      # postiz-postgres or postiz-redis services below.
      DATABASE_URL: "postgresql://postiz-user:postiz-password@postiz-postgres:5432/postiz-db-local"
      REDIS_URL: "redis://postiz-redis:6379"
      BACKEND_INTERNAL_URL: "http://localhost:3000"
      IS_GENERAL: "true" # Required for self-hosting.
 
      # The container images are pre-configured to use /uploads for file storage.
      # You probably should not change this unless you have a really good reason!
      STORAGE_PROVIDER: "local"
      UPLOAD_DIRECTORY: "/uploads"
      NEXT_PUBLIC_UPLOAD_DIRECTORY: "/uploads"
    volumes:
      - postiz-config:/config/
      - postiz-uploads:/uploads/
    ports:
      - 5000:5000
    networks:
      - postiz-network
    labels:
      - "traefik.enable=true"
      - "traefik.https.routers.<unique_router_name>.rule=Host(`coolify.io`) && PathPrefix(`/`)"
      - "traefik.https.routers.<unique_router_name>.entryPoints=https"
    depends_on:
      postiz-postgres:
        condition: service_healthy
      postiz-redis:
        condition: service_healthy
 
  postiz-postgres:
    image: postgres:14.5
    container_name: postiz-postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: postiz-password
      POSTGRES_USER: postiz-user
      POSTGRES_DB: postiz-db-local
    volumes:
      - postgres-volume:/var/lib/postgresql/data
    ports:
      - 5432:5432
    networks:
      - postiz-network
    healthcheck:
      test: pg_isready -U postiz-user -d postiz-db-local
      interval: 10s
      timeout: 3s
      retries: 3
  postiz-redis:
    image: redis:7.2
    container_name: postiz-redis
    restart: always
    ports:
      - 6379:6379
    healthcheck:
      test: redis-cli ping
      interval: 10s
      timeout: 3s
      retries: 3
    volumes:
      - postiz-redis-data:/data
    networks:
      - postiz-network
 
 
volumes:
  postgres-volume:
    external: false
 
  postiz-redis-data:
    external: false
 
  postiz-config:
    external: false
 
networks:
  postiz-network:
    external: false
