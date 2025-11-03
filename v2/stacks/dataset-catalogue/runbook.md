# Dataset Catalogue - Operational Runbook

## Service Overview

The **Dataset Catalogue** service provides an inventory and discovery interface for datasets across the ONS Digital Publishing ecosystem. It exposes both API and user interface layers that enable:

- **Public users** to browse available datasets, inspect metadata, and determine suitability for use.  
- **Internal publishers and administrators** to manage, curate, and release datasets through controlled publication workflows.  

The service integrates with downstream APIs to aggregate dataset metadata, bundle releases, and provide filtering and download capabilities. It is a key part of the **Dataset Publication pipeline**, bridging the data storage layer (`dp-dataset-api`) and presentation layer (`dis-dataset-admin-ui` and frontend controllers).

**Key Functions:**
- Dataset versioning and metadata storage
- Dataset filtering and custom download generation  
- Bundle creation and publication workflow
- File management and storage operations
- User permissions and access control
- Administrative web interfaces

**Service Classification:**
- **Internal Services** (`ENABLE_PRIVATE_ENDPOINTS=true`): dp-dataset-api, dp-permissions-api, dis-bundle-api, dis-bundle-scheduler
- **Public Services** (`ENABLE_PRIVATE_ENDPOINTS=false`): dp-frontend-dataset-controller, dis-data-admin-ui
- **Routing Services**: dp-api-router (handles both internal and external requests)

## Architecture Diagram


## List of Dependencies with Stakeholders

### Internal Services
| Service | Function | Stakeholder | Contact |
|---------|----------|-------------|---------|
| [`../dp-dataset-api`](../../../dp-dataset-api) | Dataset metadata storage and versioning | OFS Back-end Developers | #dp-backend-dev |
| [`../dp-filter-api`](../../../dp-filter-api) | Dataset filtering and downloads | OFS Back-end Developers | #dp-backend-dev |
| [`../dis-bundle-api`](../../../dis-bundle-api) | Bundle publication workflow | OFS Back-end Developers | #dp-backend-dev |
| [`../dis-bundle-scheduler`](../../../dis-bundle-scheduler) | Scheduled publication automation | OFS Back-end Developers | #dp-backend-dev |
| [`../dp-permissions-api`](../../../dp-permissions-api) | User/service permissions management | OFS Back-end Developers | #dp-backend-dev |
| [`../dis-data-admin-ui`](../../../dis-data-admin-ui) | Administrative web interface | OFS Front-end developers | #dp-frontend-dev |
| [`../dp-files-api`](../../../dp-files-api) | File storage operations | Team Open Source | #team-open-source |
| [`../dp-api-router`](../../../dp-api-router) | API request routing and load balancing | Team Open Source | #team-open-source |


### External Dependencies
| Service | Function | Stakeholder | Contact |
|---------|----------|-------------|---------|
| MongoDB | Database storage for metadata | Infrastructure Team | #infrastructure |
| LocalStack S3 | File storage simulation | Development Infrastructure | #dev-infrastructure |
| Kafka | Event streaming for service communication | Infrastructure Team | #infrastructure |

## Start/Stop/Restart Instructions
## Escalation Contacts
## Known Limitations
