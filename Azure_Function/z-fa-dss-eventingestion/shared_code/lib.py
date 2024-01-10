import pytz
from datetime import datetime
import json
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import os
import logging
from dataclasses import dataclass


def get_local_date_time():
    # Convert UTC to local time (NZST)
    local_tz = pytz.timezone('Pacific/Auckland')
    time_utc = datetime.utcnow()
    return time_utc.replace(tzinfo=pytz.utc).astimezone(local_tz)


def get_date_time_partition():
    # Create a partition string
    local_date_time = get_local_date_time()
    blob_date = local_date_time.strftime("%Y%m%d")
    blob_hour = local_date_time.strftime("%H")
    return f"load_date={blob_date}/hour={blob_hour}"


def ingest_message(p_message, p_file_path, p_msg_id):

    try:
        # Autheticate to blob storage using managed identity
        account_url = os.environ['BlobStorage__serviceUri']
        default_credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(account_url, credential=default_credential)
        msg_body = p_message
        json_msg = json.loads(msg_body.decode('utf-8'))

        # Removing Indentation if existing in the source
        json_msg_single_line = json.dumps(json_msg, separators=(",", ":"))

        # ignore case type
        target_key = p_msg_id.lower()
        matching_keys = [key for key in json_msg.keys() if key.lower() == target_key]

        if not matching_keys:
            logging.warning(f"No matching key found for {p_msg_id} in the JSON.")

        actual_msg_id = matching_keys[0]
        # logging.info(actual_msg_id)
        # logging.info(json_msg)

        # Create the file write location
        date_time_partition = get_date_time_partition()
        write_location = f"source-data/{p_file_path}{date_time_partition}"
        # blob name construct
        local_date_time = get_local_date_time()
        file_date = local_date_time.strftime("%Y%m%d%H%M%S%Z%z")
        blob_name = f"{file_date}-{json_msg[actual_msg_id]}.json"
        # Writing file on the ADLS
        container_client = blob_service_client.get_container_client(write_location)
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(json_msg_single_line, overwrite=True)
        logging.info(f"Successfully processed event message {json_msg[actual_msg_id]}")
    except Exception as e:
        logging.exception(f"Processing Function failed with error: {e}")
        raise e


@dataclass
class PumpedEventTopicLookup:
    event_type: str

    def get_topic_name(self):
        lookup_dict = {
            "balance": "external.targetedoffers.ibalanceintegrationevent",
            "spend": "external.targetedoffers.icpltransactionspendintegrationevent",
            "spendReversal": "external.targetedoffers.icpltransactionspendreversalintegrationevent",
            "save": "external.targetedoffers.icpltransactionsaveintegrationevent",
            "saveReversal": "external.targetedoffers.icpltransactionsavereversalintegrationevent",
            "externalSpend": "external.flybuyscpl.iexternalcplspendcreatedintegrationevent",
            "externalSpendReversal": "external.flybuyscpl.iexternalcplspendreversedintegrationevent",
            "balanceTransfer": "external.zenergy.icpltransactionbalancetransferintegrationevent"
        }
        return lookup_dict[self]
