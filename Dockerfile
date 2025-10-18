FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CustomerDetails.csproj", "CustomerDetails/"]
RUN dotnet restore "CustomerDetails/CustomerDetails.csproj"
COPY . .
WORKDIR "/src/CustomerDetails"
RUN dotnet build "CustomerDetails.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /src/CustomerDetails/appsettings.json .
COPY --from=build /src/CustomerDetails/appsettings.Development.json .
COPY --from=build /app/build .
EXPOSE 8080
ENTRYPOINT ["dotnet", "CustomerDetails.dll"]
