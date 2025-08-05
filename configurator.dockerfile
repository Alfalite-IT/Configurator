# Build stage
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN flutter build web --dart-define=API_BASE_URL=https://app.alfalite.com/api \
                     --dart-define=SERVER_BASE_URL=https://app.alfalite.com/api \
                     --dart-define=ENVIRONMENT=production

# Production stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]