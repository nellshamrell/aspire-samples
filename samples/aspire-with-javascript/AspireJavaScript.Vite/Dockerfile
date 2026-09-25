FROM node:24 AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --registry=https://packagefeedproxy.microsoft.io/npm/

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
