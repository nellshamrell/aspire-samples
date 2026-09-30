FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src
COPY AspireJavaScript.MinimalApi/AspireJavaScript.MinimalApi.csproj AspireJavaScript.MinimalApi/
COPY AspireJavaScript.ServiceDefaults/AspireJavaScript.ServiceDefaults.csproj AspireJavaScript.ServiceDefaults/
RUN dotnet restore AspireJavaScript.MinimalApi/AspireJavaScript.MinimalApi.csproj

COPY AspireJavaScript.MinimalApi/ AspireJavaScript.MinimalApi/
COPY AspireJavaScript.ServiceDefaults/ AspireJavaScript.ServiceDefaults/
RUN dotnet publish AspireJavaScript.MinimalApi/AspireJavaScript.MinimalApi.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "AspireJavaScript.MinimalApi.dll"]
