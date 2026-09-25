extension radius

param environment string

@secure()
param postgresPassword string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource aspireShopApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'aspire-shop'
  properties: {
    environment: environment
  }
}

resource postgresDb 'Radius.Data/postgreSqlDatabases@2025-08-01-preview' = {
  name: 'postgres'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.CatalogDbManager/Program.cs#L8'
    database: 'catalogdb'
    password: postgresPassword
    size: 'S'
    tls: 'required'
    username: 'myadmin'
  }
}

resource redisCache 'Radius.Data/redisCaches@2025-08-01-preview' = {
  name: 'redis'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.BasketService/Program.cs#L7'
    size: 'S'
  }
}

resource catalogDbConnection 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'catalog-db-connection'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.CatalogDbManager/Program.cs#L8'
    data: {
      connectionString: {
        value: 'Host=${postgresDb.properties.host};Port=5432;Database=catalogdb;Username=myadmin;Password=${postgresPassword};SSL Mode=Require'
      }
    }
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: '.radius/app.bicep#L56'
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

resource basketServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'basketservice-image'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.BasketService/Dockerfile#L1'
    tag: 'basketservice-5fc02136027f'
    build: {
      dockerfile: 'AspireShop.BasketService/Dockerfile'
      platforms: [
        'linux/amd64'
        'linux/arm64'
      ]
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-shop?ref=5fc02136027f845fc1b37ccf62cfbb6cae709290'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource catalogDbManagerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'catalogdbmanager-image'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.CatalogDbManager/Dockerfile#L1'
    tag: 'catalogdbmanager-5fc02136027f'
    build: {
      dockerfile: 'AspireShop.CatalogDbManager/Dockerfile'
      platforms: [
        'linux/amd64'
        'linux/arm64'
      ]
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-shop?ref=5fc02136027f845fc1b37ccf62cfbb6cae709290'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource catalogServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'catalogservice-image'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.CatalogService/Dockerfile#L1'
    tag: 'catalogservice-5fc02136027f'
    build: {
      dockerfile: 'AspireShop.CatalogService/Dockerfile'
      platforms: [
        'linux/amd64'
        'linux/arm64'
      ]
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-shop?ref=5fc02136027f845fc1b37ccf62cfbb6cae709290'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource frontendImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'frontend-image'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.Frontend/Dockerfile#L1'
    tag: 'frontend-5fc02136027f'
    build: {
      dockerfile: 'AspireShop.Frontend/Dockerfile'
      platforms: [
        'linux/amd64'
        'linux/arm64'
      ]
      source: 'git::https://github.com/nellshamrell/aspire-samples.git//samples/aspire-shop?ref=5fc02136027f845fc1b37ccf62cfbb6cae709290'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource basketServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'basketservice'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.BasketService/Program.cs#L21'
    containers: {
      basketservice: {
        image: basketServiceImage.properties.imageReference
        command: [
          '/bin/sh'
          '-c'
        ]
        args: [
          'URL="$ConnectionStrings__basketcache"; REST="\${URL#*://}"; CREDENTIALS="\${REST%%@*}"; HOSTPORT="\${REST#*@}"; PASSWORD="\${CREDENTIALS#:}"; export ConnectionStrings__basketcache="\${HOSTPORT},password=\${PASSWORD},ssl=True,abortConnect=False"; exec dotnet AspireShop.BasketService.dll'
        ]
        env: {
          ConnectionStrings__basketcache: {
            valueFrom: {
              secretKeyRef: {
                secretName: redisCache.properties.secrets.name
                key: 'url'
              }
            }
          }
        }
        ports: {
          grpc: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource catalogDbManagerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'catalogdbmanager'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.CatalogDbManager/Program.cs#L34'
    containers: {
      catalogdbmanager: {
        image: catalogDbManagerImage.properties.imageReference
        env: {
          ConnectionStrings__catalogdb: {
            valueFrom: {
              secretKeyRef: {
                secretName: catalogDbConnection.name
                key: 'connectionString'
              }
            }
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource catalogServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'catalogservice'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.CatalogService/Program.cs#L29'
    containers: {
      catalogservice: {
        image: catalogServiceImage.properties.imageReference
        env: {
          ConnectionStrings__catalogdb: {
            valueFrom: {
              secretKeyRef: {
                secretName: catalogDbConnection.name
                key: 'connectionString'
              }
            }
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
  dependsOn: [
    catalogDbManagerContainer
  ]
}

resource frontendContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'frontend'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.Frontend/Program.cs#L40'
    containers: {
      frontend: {
        image: frontendImage.properties.imageReference
        env: {
          services__basketservice__http__0: {
            value: 'http://${basketServiceContainer.properties.hosts['basketservice']}:8080'
          }
          services__catalogservice__http__0: {
            value: 'http://${catalogServiceContainer.properties.hosts['catalogservice']}:8080'
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
  }
}

resource frontendRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'frontend'
  properties: {
    environment: environment
    application: aspireShopApp.id
    codeReference: 'samples/aspire-shop/AspireShop.AppHost/AppHost.cs#L35'
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          containerName: 'frontend'
          containerPort: 8080
          resourceId: frontendContainer.id
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}
