# Machine Learning on Streaming Pipelines

### Catch up from previous chapters if necessary
If you didn't go through Chapters 2-9, the simplest way to catch up is to copy data from my bucket:

#### Catch up from Chapters 2-9
* Open CloudShell and git clone this repo:
    ```
    git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp
    ```
* Go to the 02_ingest folder of the repo, run the program ./ingest_from_crsbucket.sh and specify your bucket name.
* Go to the 04_streaming folder of the repo, run the program ./ingest_from_crsbucket.sh and specify your bucket name.
* Go to the 05_bqnotebook folder of the repo, run the script to load data into BigQuery:
	```
	bash create_trainday.sh <BUCKET-NAME>
	```

#### From CloudShell
* Install the Python libraries you'll need
    ```
    pip3 install google-cloud-aiplatform cloudml-hypertune pyfarmhash
    ```
* [Optional] Create a small, local sample of BigQuery datasets for local experimentation:
    ```
    bash create_sample_input.sh
    ```
* [Optional] Run a local pipeline to create a training dataset:
    ```
    python3 create_traindata.py --input local
    ```
   Verify the results:
   ```
   cat /tmp/all_data*
   ```
* Run a Dataflow pipeline to create the full training dataset:
  ```
    python3 create_traindata.py --input bigquery --project <PROJECT> --bucket <BUCKET> --region <REGION>
  ```
* Copy over the Ch10 model.py and train_on_vertexai.py files and make the necessary changes:
  ```
  python3 change_ch10_files.py
  ```
* [Optional] Train an AutoML model on the enriched dataset:
  ```
  python3 train_on_vertexai.py --automl --project <PROJECT> --bucket <BUCKET> --region <REGION>
  ```
  Verify performance by running the following BigQuery query:
  ```
  SELECT  
  SQRT(SUM(
      (CAST(ontime AS FLOAT64) - predicted_ontime.scores[OFFSET(0)])*
      (CAST(ontime AS FLOAT64) - predicted_ontime.scores[OFFSET(0)])
      )/COUNT(*))
  FROM dsongcp.ch11_automl_evaluated
  ```
* Train custom ML model on the enriched dataset:
  ```
  python3 train_on_vertexai.py --project <PROJECT> --bucket <BUCKET> --region <REGION>
  ```
  Look at the logs of the log to determine the final RMSE.
* Run a local pipeline to invoke predictions:
    ```
    python3 make_predictions.py --input local
    ```
   Verify the results:
   ```
   cat /tmp/predictions*
   ```
* [Optional] Run a pipeline on full BigQuery dataset to invoke predictions:
    ```
    python3 make_predictions.py --input bigquery --project <PROJECT> --bucket <BUCKET> --region <REGION>
    ```
   Verify the results
   ```
   gsutil cat gs://BUCKET/flights/ch11/predictions* | head -5
   ```
* [Optional] Simulate real-time pipeline and check to see if predictions are being made

  
   In one terminal, type:
    ```
  cd ../04_streaming/simulate
  python3 ./simulate.py --startTime '2015-05-01 00:00:00 UTC' \
           --endTime '2015-05-04 00:00:00 UTC' --speedFactor=30 --project <PROJECT>
    ```
   
  In another terminal type:
    ```
    python3 make_predictions.py --input pubsub \
           --project <PROJECT> --bucket <BUCKET> --region <REGION>
    ```
  
  Ensure that the pipeline starts, check that output elements are starting to be written out, do:
   ```
   gsutil ls gs://BUCKET/flights/ch11/predictions*
   ```
   Make sure to go to the GCP Console and stop the Dataflow pipeline.

  
* Simulate real-time pipeline and try out different jagger etc.

  In one terminal, type:
    ```
  cd ../04_streaming/simulate
  python3 ./simulate.py --startTime '2015-02-01 00:00:00 UTC' \
           --endTime '2015-02-03 00:00:00 UTC' --speedFactor=30 --project <PROJECT>
    ```
   
  In another terminal type:
    ```
    python3 make_predictions.py --input pubsub --output bigquery \
           --project <PROJECT> --bucket <BUCKET> --region <REGION>
    ```
  
  Ensure that the pipeline starts, look at BigQuery:
   ```
   SELECT * FROM dsongcp.streaming_preds ORDER BY event_time DESC LIMIT 10
   ```
   When done, make sure to go to the GCP Console and stop the Dataflow pipeline.
   
   Note: If you are going to try it a second time around, delete the BigQuery sink, or simulate with a different time range
   ```
   bq rm -f dsongcp.streaming_preds
   ```
  
