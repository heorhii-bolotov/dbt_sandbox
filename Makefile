# make run - Execute the command

VENV = venv
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip

USER = cloud_user_p_1a7c26e2@linuxacademygclabs.com
PROJECT_ID = playground-s-11-6a75076f
DATASET = dl_northwind
LOCATION = europe-west1

DBT_PROJECT_ID = ae_bootcamp

.PHONY: run clean

run: $(VENV)/bin/activate
	echo Setting up environment and Running Script

dbt_init: $(VENV)/bin/activate
	echo N | dbt init --profiles-dir ./configs --profile profiles.yml $(DBT_PROJECT_ID) # don't overwrite the profiles.yml file
	cd $(DBT_PROJECT_ID) && dbt debug --profiles-dir ../configs/ && dbt run --profiles-dir ../configs/

$(VENV)/bin/activate: requirements.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.txt

clean:
	rm -rf __pycache__
	rm -rf $(VENV)

gcp_setup:
	gcloud init
	echo Y | gcloud config set account $(USER)
	gcloud auth application-default login
	echo Y | gcloud config set project $(PROJECT_ID)

dataset:
	bq --location=$(LOCATION) mk --dataset $(PROJECT_ID):$(DATASET)

source:
	bq mk \
		-t \
		--expiration 3600 \
		--description "This is my table" \
		--label $(PROJECT_ID):$(DATASET) \
		$(DATASET).example \
		qtr:STRING,sales:FLOAT,year:STRING
	bq query --use_legacy_sql=false "$(cat ./resources/dl_northwind_sql/northwind_oltp_bq_schemacreate-tables-script.sql)"
	bq query --use_legacy_sql=false "$(cat ./resources/dl_northwind_sql/nortwind_oltp_datainsert-data-script.sql)"
