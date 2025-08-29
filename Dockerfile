# Use the official .NET 8 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY src/TaskManagementApi/*.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY src/TaskManagementApi/. ./
RUN dotnet publish -c Release -o out

# Use the official .NET 8 ASP.NET runtime image for running
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/out ./

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["dotnet", "TaskManagementApi.dll"]