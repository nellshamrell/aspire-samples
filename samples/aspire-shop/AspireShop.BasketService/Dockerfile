FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build

ARG TARGETARCH
WORKDIR /src
COPY . .
RUN dotnet publish AspireShop.BasketService/AspireShop.BasketService.csproj \
    --arch $TARGETARCH \
    --configuration Release \
    --no-self-contained \
    --output /app/publish \
    -p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0

WORKDIR /app
COPY --from=build /app/publish .
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "AspireShop.BasketService.dll"]
