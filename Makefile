# make run - Execute the command

VENV = venv
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip

USER = cloud_user_p_e8f4f9be@linuxacademygclabs.com
PROJECT_ID = playground-s-11-1f7eda48
DATASET = dl_northwind
LOCATION = europe-west1

.PHONY: run clean

run: $(VENV)/bin/activate
	echo Setting up environment and Running Script

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
	bq query --use_legacy_sql=false "$(cat ./resources/dl_northwind_sql/northwind_oltp_bq_schemacreate-tables-script.sql)"
	bq query --use_legacy_sql=false "$(cat ./resources/dl_northwind_sql/nortwind_oltp_datainsert-data-script.sql)"