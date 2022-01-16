import json
from transformers import pipeline
import os

os.environ['TRANSFORMERS_CACHE'] = '/mnt/access/transformers'
nlp = pipeline("sentiment-analysis")

def handler(event, context):
    response = {
        "statusCode": 200,
        "body": nlp(event['text'])[0]
    }
    return response