FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CustomerDetails.csproj", "."]
RUN dotnet restore "CustomerDetails.csproj"
COPY . .
RUN dotnet build "CustomerDetails.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /src/appsettings.json .
COPY --from=build /src/appsettings.Development.json .
COPY --from=build /app/build .
# تعيين متغير البيئة للبورت
ENV ASPNETCORE_URLS=http://0.0.0.0:$PORT
ENV ASPNETCORE_ENVIRONMENT=Production
EXPOSE $PORT
ENTRYPOINT ["dotnet", "CustomerDetails.dll"]
