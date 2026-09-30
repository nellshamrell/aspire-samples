# Integrating Angular, React, and Vue with Aspire

This sample demonstrates using the Aspire JavaScript hosting integration to configure and run client-side applications.

The app consists of five services:

- **AspireJavaScript.MinimalApi**: This is an HTTP API that returns randomly generated weather forecast data.
- **AspireJavaScript.Angular**: An Angular app that consumes the weather forecast API and displays it with a featured-day hero and supporting day cards.
- **AspireJavaScript.React**: A React app (Webpack) that consumes the weather forecast API and displays the forecast.
- **AspireJavaScript.Vue**: A Vue app that consumes the weather forecast API and presents the forecast as a swipeable, keyboard-navigable day-by-day carousel.
- **AspireJavaScript.Vite**: A React + Vite + TypeScript app that consumes the weather forecast API and displays the forecast.

The four front ends all render the **same** weather data, but each one wears a **completely different design identity** — the point of the sample is to compare the frameworks side by side, so we lean into that contrast:

| Front end | Design identity | CSS approach | Icon set |
| --- | --- | --- | --- |
| **Angular** | Material 3 "expressive" — dynamic tonal color, elevated surfaces | Angular Material + SCSS | Material Symbols |
| **React** | Neo-brutalism — thick borders, hard offset shadows, chunky type | CSS Modules | Phosphor |
| **Vue** | Forecast carousel — soft cards, Vue-green gradients, day-by-day navigation | Scoped CSS + custom properties | Lucide |
| **Vite** | Retro synthwave — neon sun, 80s grid horizon | Tailwind CSS | Tabler |

Every front end is keyboard operable, ships a skip link, announces async state with `aria-live`, honors `prefers-reduced-motion` and `prefers-color-scheme`, and passes an automated `axe-core` accessibility scan in both light and dark themes.

## Pre-requisites

- [Aspire development environment](https://aspire.dev/get-started/prerequisites/)
- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- [Node.js](https://nodejs.org) - at least version 24.x

## Running the app

If using the Aspire CLI, run `aspire run` from this directory.

If using VS Code, open this directory as a workspace and launch the `AspireJavaScript.AppHost` project using either the Aspire or C# debuggers.

If using Visual Studio, open the solution file `AspireJavaScript.slnx` and launch/debug the `AspireJavaScript.AppHost` project.

If using the .NET CLI, run `dotnet run` from the `AspireShop.AppHost` directory.

## Deploy the React weather demo with Radius Canvas

This deployment uses the **weather API and React frontend** (not Angular, Vue, or Vite). The API runs in a .NET container; Nginx serves React and proxies `/api/` to the API over the cluster network. The model is at [`.radius/app.bicep`](../../.radius/app.bicep).

1. Install the **Radius** plugin in the GitHub Copilot app's **Customize > Plugins** tab, then restart your session. Open this GitHub repository in a Copilot worktree.
2. Ask Copilot: **"Show the application graph for the React weather demo."** In Radius Canvas, check for two container images, two containers, and a route to React. Commit and push `.radius/app.bicep`, `.radius/bicepconfig.json`, and the sample's Dockerfiles before deploying; Radius builds the images from the **commit SHA pinned in the model's `build.source` URLs**. If you change either image's source, commit it and update both URLs to the new source commit.
3. In Canvas, select **Create Environment**. Connect an Azure credential profile with GitHub OIDC access to an AKS cluster, choose a dedicated namespace, and finish verification. The GitHub Environment must have a private repository-linked GHCR state package and `RADIUS_STATE_BACKEND=oci`, `RADIUS_STATE_REGISTRY=ghcr.io/<owner>/<private-state-package>` (no tag), and `RADIUS_STATE_ARCHIVE=radius-state`. The GitHub account used for setup needs `read:packages` and `write:packages`.
4. Open **Planned**, select this branch and the verified Environment, and review the two workloads and the React route. For this AKS cluster, dispatch the Canvas-generated deploy workflow with `gh workflow run run-rad-commands.yml --ref <branch> -f environment=<environment>`. The Canvas **Deploy Application** button currently regenerates the Azure workflow without the AKS token fix in this branch, so use the workflow dispatch until that generator is fixed. Follow its run in GitHub Actions; then view the resources in Canvas **Deployed**.
5. Run `gh workflow run verify-javascript-weather.yml --ref <branch> -f environment=<environment>` and check that it passes. This tests the React page and the five-forecast JSON response through the frontend's `/api/` proxy. Ask Copilot **"Access my deployed application"** to port-forward React and try **Refresh** yourself. When finished, use **Delete Deployment** in Canvas, then delete the Environment if it is no longer needed.

See the [Radius Canvas guide](https://docs.radapp.io/integrations/github-copilot-app/canvas-extension/) for the plugin and Environment setup screens.

### Experiencing the app

Once the app is running, the Aspire dashboard will launch in your browser:

![Aspire dashboard](./images/aspire-dashboard.png)

From the dashboard, you can navigate to the Angular, React, Vue, and Vite apps.

**Angular** — Material 3 expressive

![Angular app (light)](./images/angular-app-light.png#gh-light-mode-only)
![Angular app (dark)](./images/angular-app-dark.png#gh-dark-mode-only)

**React** — Neo-brutalism

![React app (light)](./images/react-app-light.png#gh-light-mode-only)
![React app (dark)](./images/react-app-dark.png#gh-dark-mode-only)

**Vue** — Forecast carousel

![Vue app (light)](./images/vue-app-light.png#gh-light-mode-only)
![Vue app (dark)](./images/vue-app-dark.png#gh-dark-mode-only)

**Vite** — Retro synthwave

![Vite app (light)](./images/reactvite-app-light.png#gh-light-mode-only)
![Vite app (dark)](./images/reactvite-app-dark.png#gh-dark-mode-only)
