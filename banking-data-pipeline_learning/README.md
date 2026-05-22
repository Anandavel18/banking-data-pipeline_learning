# banking-data-pipeline_learning
Banking Data Pipeline (dbt + Terraform + GitHub Actions + GCP)
________________________________________
Architecture Overview
This project implements a modern cloud-based data pipeline using:
•	GitHub Actions for CI/CD automation 
•	dbt for data transformation and testing 
•	Terraform for infrastructure validation 
•	Google Cloud BigQuery as the data warehouse 
•	Workload Identity Federation (WIF) for secure authentication (no service account keys) 
________________________________________
High-Level Flow
GitHub Push / PR
        ↓
GitHub Actions CI Pipeline
        ↓
Workload Identity Federation (GCP Auth)
        ↓
dbt:
  - install dependencies
  - run transformations
  - execute data tests
        ↓
Terraform:
  - format check
  - init
  - validate
        ↓
BigQuery (Data Warehouse)
________________________________________
Components
CI/CD	GitHub Actions	Automation pipeline
Transformation	dbt	Data modeling + testing
Infrastructure	Terraform	GCP infrastructure validation
Warehouse	BigQuery	Data storage
Auth	WIF (GCP)	Secure authentication
________________________________________
1) GCP Setup
1.1 Enable APIs
Enable:
•	IAM API 
•	IAM Credentials API 
•	BigQuery API 
________________________________________
1.2 Create Workload Identity Pool
github-pool
________________________________________
1.3 Create Provider
Issuer
https://token.actions.githubusercontent.com
________________________________________
Attribute Mapping
google.subject=assertion.sub
attribute.repository=assertion.repository
________________________________________
Attribute Condition
attribute.repository == "Anandavel18/banking-data-pipeline_learning"
________________________________________
1.4 Create Service Account
banking-migration-test@PROJECT_ID.iam.gserviceaccount.com
________________________________________
1.5 IAM Role Binding
Assign:
roles/iam.workloadIdentityUser
roles/bigquery.admin   (or dataset-specific role)
________________________________________
1.6 Bind WIF to Service Account
gcloud iam service-accounts add-iam-policy-binding \
  banking-migration-test@PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/Anandavel18/banking-data-pipeline_learning"
________________________________________
2. Terraform Setup
2.1 Initialize Terraform
cd Techincal_Exercise/terraform
terraform init
________________________________________
2.2 Validate Configuration
terraform fmt -check -recursive
terraform validate
________________________________________
2.3 (Optional) Plan
terraform plan
________________________________________
3.  dbt Setup
3.1 Install dependencies
pip install dbt-core dbt-bigquery
________________________________________
3.2 Install packages
dbt deps
________________________________________
3.3 Run pipeline locally
dbt run
dbt test
________________________________________
3.4 profiles.yml location
Techincal_Exercise/banking_migration_dbt/profiles.yml
________________________________________
3.5 dbt profile config
banking_migration_dbt:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: PROJECT_ID
      dataset: dbt_default
      location: EU
      threads: 4
________________________________________
4.  GitHub Actions CI/CD
4.1 Trigger
CI runs on:
•	Push to main 
•	Pull requests 
________________________________________
4.2 Required permissions
permissions:
  id-token: write
  contents: read
________________________________________
4.3 Pipeline steps
•	Checkout code 
•	Authenticate to GCP via WIF 
•	Install Python + dbt 
•	Run dbt: 
o	deps 
o	compile 
o	test 
•	Run Terraform: 
o	fmt 
o	init 
o	validate 
________________________________________
5.  Run Pipeline
Step 1 — Push code
git add .
git commit -m "run ci pipeline"
git push origin main
________________________________________
Step 2 — Check GitHub Actions
Go to:
👉 GitHub → Actions tab
________________________________________
Step 3 — Expected result
✔ Authentication successful
✔ dbt deps passed
✔ dbt compile passed
✔ dbt test passed
✔ terraform validate passed
✔ CI pipeline successful
________________________________________
Assumptions
________________________________________
1. GCP Setup
•	GCP project already created 
•	BigQuery API enabled 
•	IAM permissions granted correctly 
________________________________________
2. Authentication
•	Workload Identity Federation is used (no JSON keys) 
•	GitHub repo name matches attribute condition exactly 
________________________________________
3. dbt
•	Data exists in BigQuery tables 
•	Profiles.yml is correctly configured 
•	dbt version compatible with BigQuery adapter 
________________________________________
4. Terraform
•	Only validation is performed in CI 
•	No remote backend is required for CI run 
________________________________________
5. Repository
•	Default branch is main 
•	.github/workflows/ci.yml exists 
________________________________________
Summary
This project demonstrates:
✔ Cloud-native authentication (WIF)
✔ Data transformation with dbt
✔ Infrastructure validation with Terraform
✔ Fully automated CI/CD using GitHub Actions
✔ Production-grade data quality testing
