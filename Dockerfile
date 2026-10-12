FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY src/ReportingEngine.Api/ReportingEngine.Api.csproj src/ReportingEngine.Api/
RUN dotnet restore src/ReportingEngine.Api/ReportingEngine.Api.csproj
COPY src/ src/
RUN dotnet publish src/ReportingEngine.Api/ReportingEngine.Api.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app .
RUN mkdir /data && chown app /data
USER app
ENV ASPNETCORE_URLS=http://+:8080 \
    ConnectionStrings__Default="Data Source=/data/reporting.db" \
    Reports__StoragePath=/data/reports
VOLUME /data
EXPOSE 8080
ENTRYPOINT ["dotnet", "ReportingEngine.Api.dll"]
