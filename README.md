# Kyle's Resume Challenge - GCP README

This is a repository of files for the google cloud resume challenge

Status of Deployment Pipelines:
[![Update cloud infrastructure](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/workflow.yml/badge.svg)](https://github.com/kchrzanowski3/gcpresumechallenge/actions/workflows/workflow.yml)


![CI/CD Pipeline](https://github.com/kchrzanowski3/gcpresumechallenge/blob/main/readme-images/pipeline.png?raw=true)
The CI/CD Pipeline only runs in production right now. Vulnerability test results are stored in GCP. 
Future enhancements:
- Finish terraform definition so a test environment can be spun up before prod push
- Add true artifactory application
- Require vulnerability below risk level in artifactory for push to prod 
- 3 Muskateers & docker use


![GCP Architecture](https://github.com/kchrzanowski3/gcpresumechallenge/blob/main/readme-images/architecture.png?raw=true)
The GCP Architecture as it is currently defined. Not all infrastructure and service accounts are defined by terraform. 
