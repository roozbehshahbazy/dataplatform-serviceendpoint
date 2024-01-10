import azure.functions as func
from shared_code.lib import ingest_message


def main(msg: func.ServiceBusMessage):
    try:
        msg_body = msg.get_body()
        file_path = "infinity_loyalty/event-pumped_cpl_balance/"
        msg_id = "MessageId"
        ingest_message(msg_body, file_path, msg_id)
    except Exception:
        raise Exception("Processing Event Failed...")
