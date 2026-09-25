FROM node:24 AS frontend-build

WORKDIR /src/AspireJavaScript.Vite

COPY AspireJavaScript.Vite/package.json AspireJavaScript.Vite/package-lock.json ./
RUN npm ci --registry=https://packagefeedproxy.microsoft.io/npm/

COPY AspireJavaScript.Vite/ ./
RUN npm run build

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS api-build

WORKDIR /src

COPY AspireJavaScript.MinimalApi/AspireJavaScript.MinimalApi.csproj AspireJavaScript.MinimalApi/
COPY AspireJavaScript.ServiceDefaults/AspireJavaScript.ServiceDefaults.csproj AspireJavaScript.ServiceDefaults/
RUN dotnet restore AspireJavaScript.MinimalApi/AspireJavaScript.MinimalApi.csproj \
    --source https://packagefeedproxy.microsoft.io/nuget/v3/index.json

COPY AspireJavaScript.MinimalApi/ AspireJavaScript.MinimalApi/
COPY AspireJavaScript.ServiceDefaults/ AspireJavaScript.ServiceDefaults/
RUN dotnet publish AspireJavaScript.MinimalApi/AspireJavaScript.MinimalApi.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    /p:UseAppHost=false

COPY --from=frontend-build /src/AspireJavaScript.Vite/dist /app/publish/wwwroot

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

COPY --from=api-build /app/publish ./

ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080

USER $APP_UID
ENTRYPOINT ["dotnet", "AspireJavaScript.MinimalApi.dll"]
