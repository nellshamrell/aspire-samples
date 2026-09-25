extension radius

param environment string

@secure()
param registryPassword string

@secure()
param registryUsername string

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
    codeReference: '.radius/app.bicep#L17'
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

resource angularImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'angular-image'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.Angular/Dockerfile#L1'
    tag: '99731007d0c5'
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-with-javascript/AspireJavaScript.Angular?ref=99731007d0c5d1f0011626e70a537522b0522a24'
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
  name: 'react-image'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.React/Dockerfile#L1'
    tag: '99731007d0c5'
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-with-javascript/AspireJavaScript.React?ref=99731007d0c5d1f0011626e70a537522b0522a24'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource vueImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'vue-image'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.Vue/Dockerfile#L1'
    tag: '99731007d0c5'
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-with-javascript/AspireJavaScript.Vue?ref=99731007d0c5d1f0011626e70a537522b0522a24'
      platforms: [
        'linux/amd64'
      ]
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource weatherapiImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'weatherapi-image'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.MinimalApi/Dockerfile#L1'
    tag: '99731007d0c5'
    build: {
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-with-javascript?ref=99731007d0c5d1f0011626e70a537522b0522a24'
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

resource angularContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'angular'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.Angular/src/main.ts#L5'
    containers: {
      angular: {
        image: angularImage.properties.imageReference
        env: {
          PORT: {
            value: '80'
          }
          services__weatherapi__https__0: {
            value: 'http://${weatherapiContainer.properties.hosts[weatherapiContainer.name]}:8080'
          }
        }
        ports: {
          web: {
            containerPort: 80
          }
        }
      }
    }
  }
}

resource reactContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'react'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.React/src/index.js#L8'
    containers: {
      react: {
        image: reactImage.properties.imageReference
        env: {
          PORT: {
            value: '80'
          }
          services__weatherapi__https__0: {
            value: 'http://${weatherapiContainer.properties.hosts[weatherapiContainer.name]}:8080'
          }
        }
        ports: {
          web: {
            containerPort: 80
          }
        }
      }
    }
  }
}

resource vueContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'vue'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.Vue/src/main.ts#L7'
    containers: {
      vue: {
        image: vueImage.properties.imageReference
        env: {
          PORT: {
            value: '80'
          }
          services__weatherapi__https__0: {
            value: 'http://${weatherapiContainer.properties.hosts[weatherapiContainer.name]}:8080'
          }
        }
        ports: {
          web: {
            containerPort: 80
          }
        }
      }
    }
  }
}

resource weatherapiContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'weatherapi'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.MinimalApi/Program.cs#L49'
    containers: {
      weatherapi: {
        image: weatherapiImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource angularRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'angular-route'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.AppHost/AppHost.cs#L11'
    kind: 'HTTP'
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: angularContainer.id
          containerName: 'angular'
          containerPort: 80
        }
      }
    ]
  }
}

resource reactRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'react-route'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.AppHost/AppHost.cs#L20'
    kind: 'HTTP'
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
          containerPort: 80
        }
      }
    ]
  }
}

resource vueRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'vue-route'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.AppHost/AppHost.cs#L29'
    kind: 'HTTP'
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: vueContainer.id
          containerName: 'vue'
          containerPort: 80
        }
      }
    ]
  }
}

resource weatherapiRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'weatherapi-route'
  properties: {
    environment: environment
    application: aspireSamplesApp.id
    codeReference: 'samples/aspire-with-javascript/AspireJavaScript.AppHost/AppHost.cs#L4'
    kind: 'HTTP'
    rules: [
      {
        matches: [
          {
            httpPath: '/'
          }
        ]
        destinationContainer: {
          resourceId: weatherapiContainer.id
          containerName: 'weatherapi'
          containerPort: 8080
        }
      }
    ]
  }
}
