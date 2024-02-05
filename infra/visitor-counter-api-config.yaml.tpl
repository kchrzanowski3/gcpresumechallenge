info:
  title: My Resume API Visitor Count Template
  description: This API is for project ${project_name}

# openapi2-functions.yaml
swagger: '2.0'
info:
  title: resumeapi descriptionexample
  description: Sample API on API Gateway with a Google Cloud Functions backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /${api_path}:
    get:
      summary: Return count of total page hits
      operationId: visitorcounter
      x-google-backend:
        address: https://${region}-${project_name}.cloudfunctions.net/${function_name}
        jwt_audience: https://${region}-${project_name}.cloudfunctions.net/${function_name}

      responses:
        '200':
          description: A successful response
          schema:
            type: string
