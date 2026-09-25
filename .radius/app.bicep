extension radius

param environment string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource golangApiApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'golang-api'
  properties: {
    environment: environment
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: golangApiApp.id
    codeReference: '.radius/app.bicep#L18'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
  }
}

resource apiImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'golang-api-image'
  properties: {
    environment: environment
    application: golangApiApp.id
    codeReference: 'samples/golang-api/api/Dockerfile#L1'
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/golang-api/api?ref=82cdf59617b31e54c72632d40dd9be9071a9ad1b'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource apiContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'golang-api'
  properties: {
    environment: environment
    application: golangApiApp.id
    codeReference: 'samples/golang-api/api/main.go#L256'
    containers: {
      api: {
        image: apiImage.properties.imageReference
        env: {
          HOST: {
            value: '0.0.0.0'
          }
          PORT: {
            value: '8080'
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
        readinessProbe: {
          httpGet: {
            path: '/health'
            port: 8080
            scheme: 'http'
          }
        }
      }
    }
  }
}

resource apiRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'golang-api-route'
  properties: {
    environment: environment
    application: golangApiApp.id
    codeReference: 'samples/golang-api/apphost.mts#L17'
    kind: 'HTTP'
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: apiContainer.id
          containerName: 'api'
          containerPort: 8080
        }
      }
    ]
  }
}
