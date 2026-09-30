extension radius

param environment string
@secure()
param registryUsername string

@secure()
param registryPassword string

resource aspireSamplesApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'aspire-samples'
  properties: {
    environment: environment
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    data: {
      username: {
        value: registryUsername
      }
      password: {
        value: registryPassword
      }
    }
  }
}

resource weatherApiImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'weather-api-image'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-with-javascript?ref=fa45d64f02c540b164d82a2cb7dfce39d74b282f'
      dockerfile: 'AspireJavaScript.MinimalApi/Dockerfile'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource reactImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'react-weather-image'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-with-javascript/AspireJavaScript.React?ref=fa45d64f02c540b164d82a2cb7dfce39d74b282f'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource weatherApiContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'weather-api'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.MinimalApi/Dockerfile'
    containers: {
      weatherApi: {
        image: weatherApiImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource reactContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'react-weather'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.React/Dockerfile'
    containers: {
      react: {
        image: reactImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
        env: {
          PORT: {
            value: '8080'
          }
          services__weatherapi__http__0: {
            value: 'http://${weatherApiContainer.properties.hosts['weatherApi']}:8080'
          }
        }
      }
    }
  }
}

resource reactRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'react-weather'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.AppHost/AppHost.cs'
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: reactContainer.id
          containerName: 'react'
          containerPort: 8080
        }
      }
    ]
  }
}
