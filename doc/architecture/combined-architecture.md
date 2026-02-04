# Combined GHBS Architecture

This diagram shows the combined architecture after merging FABS and BFYS into a single Rails monolith.

**URL:** www.get-help-buying-for-schools.service.gov.uk

**Features:**
- Buying solutions (formerly FABS)
- Request for help
- Case Management (CMS)
- Energy for Schools
- Create a spec
- Evaluate a bid
- Frameworks portal
- Surveys

```mermaid
flowchart TD
    %% Users
    SchoolUser(["👤 School user"])
    ContentEditor(["👤 Content editor"])
    ProcOps(["👤 Procurement Operations (ProcOps)"])
    Evaluator(["👤 Evaluator"])

    %% Contentful
    subgraph Contentful["Contentful"]
        GHBSContent[("GHBS Content<br/>• Categories<br/>• Solutions<br/>• Pages")]
    end

    %% Azure hosting
    subgraph Azure["Azure"]
        subgraph RailsApp["Rails Application"]
            Website["Website<br/>(Public-facing)"]
            subgraph CMSBox["Case Management System (CMS)"]
                Spacer[" "]:::hidden
                Energy["Energy"]
            end
        end
        Sidekiq["Job runner<br/>(Sidekiq)"]
        DB[("Database<br/>PostgreSQL")]
        Redis[("Redis<br/>• Queue<br/>• Cache")]
        OpenSearch[("OpenSearch")]
        ClamAV["ClamAV<br/>virus scanner"]
    end
    classDef hidden fill:none,stroke:none,color:transparent
    classDef white fill:#ffffff,stroke:#333
    class Website,Sidekiq,DB,Redis,OpenSearch,ClamAV,Energy,FABSContent,GHBSContent,DfESignIn,AzureBlob,MSGraph,Notify,Rollbar,Alerts,Analytics,Emails white
    style Contentful fill:#ede9fe
    style Azure fill:#eef2ff
    style RailsApp fill:#e0e7ff
    style CMSBox fill:#c7d2fe
    style ExternalServices fill:#e2e8f0
    style Monitoring fill:#ddd6fe
    style DfESignIn fill:#ffffff
    style AzureBlob fill:#ffffff
    style MSGraph fill:#ffffff
    style Notify fill:#ffffff
    style Rollbar fill:#ffffff
    style Alerts fill:#ffffff
    style Analytics fill:#ffffff
    style Emails fill:#ffffff
    style SchoolUser fill:#fef3c7
    style ContentEditor fill:#fef3c7
    style ProcOps fill:#fef3c7
    style Evaluator fill:#fef3c7

    %% User connections
    SchoolUser --> Website
    SchoolUser --> CMSBox
    ContentEditor --> Contentful
    ProcOps --> CMSBox
    Evaluator --> CMSBox

    %% Contentful connections
    FABSContent -- "Content API" --> Website
    GHBSContent -- "Content API" --> Website

    %% Internal Azure connections
    RailsApp <--> DB
    RailsApp <--> Redis
    Website <--> OpenSearch
    Sidekiq <--> DB
    Sidekiq <--> Redis

    %% ClamAV connection to CMS
    CMSBox <--> ClamAV

    %% External services below Azure
    subgraph ExternalServices["External Services"]
        direction LR
        DfESignIn["DfE Sign In"]
        AzureBlob["Azure Blob"]
        MSGraph["MS Graph<br/>API"]
        Notify["GOV.UK<br/>Notify"]
    end

    subgraph Monitoring["Monitoring & Analytics"]
        direction LR
        Rollbar["Error monitoring<br/>(App Insights / Rollbar)"]
        Alerts["Error alerts<br/>(Email / Teams)"]
        Analytics["DfE Analytics<br/>(Google BigQuery)"]
    end

    Emails["Emails"]

    %% Invisible links to force layout (external services below Azure)
    DB ~~~ ExternalServices
    DB ~~~ Monitoring

    %% Visible connections from Rails app
    RailsApp <--> DfESignIn
    RailsApp <--> AzureBlob
    RailsApp <--> MSGraph
    RailsApp --> Notify
    RailsApp --> Rollbar
    RailsApp --> Analytics

    %% External service connections
    MSGraph --> Emails
    Rollbar --> Alerts
```

## Key Changes from Previous Architecture

| Before (Separate Apps) | After (Combined) |
|------------------------|------------------|
| FABS on Heroku | Single app on Azure |
| BFYS on Azure | Single app on Azure |
| Two separate databases | One PostgreSQL database |
| Two Redis instances | One Redis instance |
| JSON API sync between apps | Direct database access |
| Separate deployments | Single deployment |

## Components

### Hosting
- **Azure** - Cloud hosting platform for the combined application

### Application
- **Web** - Rails web server handling HTTP requests
- **Job runner (Sidekiq)** - Background job processing

### Data Stores
- **PostgreSQL** - Primary relational database
- **Redis** - Job queue and caching
- **OpenSearch** - Full-text search for frameworks/buying solutions

### Content Management
- **Contentful** - Headless CMS with two content spaces:
  - FABS Content (buying solutions, images)
  - GHBS Self-serve (questions, tasks for guided journeys)

### External Services
- **DfE Sign In** - Authentication for school users
- **MS Graph API** - Outlook email integration for case management
- **GOV.UK Notify** - Transactional emails and notifications
- **AWS AzureBlob / Azure Blob** - File storage
- **ClamAV** - Antivirus scanning for uploads

### Monitoring & Analytics
- **Rollbar** - Error tracking and alerting
- **DfE Analytics** - Event tracking to Google BigQuery
