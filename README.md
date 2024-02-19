Cloud Architecture Diagram

The below diagram depicts the cloud infrastructure hosting: <https://kylenowski.com>

![CI/CD Pipeline](readme-images/pipeline.png?raw=true)

Highlights:

- All infrastructure including DNS records are defined as code (IaC).

- The storage bucket hosting my site contains HTML, CSS, and JavaScript.

- The JavaScript calls an API that retrieves the current hit count and stores a new value in a datastore database.

- Cross Origin Resource Sharing (CORS) set to least privilege.

- All port 80 traffic is redirected to HTTPS.

Pipeline Architecture Diagram

The below diagram depicts the various pipelines in this project

![GCP Architecture](readme-images/architecture.png?raw=true)

Highlights:

- A dedicated and separate staging environment is created for each pull request to main.

- Security and functional tests are automated and produce results (e.g., SAST, SBOM vulnerability scanning, secrets scanning,).

- Test results are visible in GitHub Advanced Security for management.

- Security and end-to-end functional tests must pass prior to approval of a pull request.

- Approved pull requests deploy the changes to production.

- The test environment is destroyed after tests confirm a successful deploy to production.

- Short lived OIDC tokens are utilized for authentication to GCP from the pipelines in lieu of long-lived access keys.

- Commits in GitHub are signed.




Status of Deployment Pipelines:

[![Cloud Resume Production](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/main-deploy.yml/badge.svg)](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/main-deploy.yml)

[![Cloud Resume Staging](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/test-deploy.yml/badge.svg)](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/test-deploy.yml)

[![Cloud Resume Security](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/static-vuln-scan.yml/badge.svg)](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/static-vuln-scan.yml)