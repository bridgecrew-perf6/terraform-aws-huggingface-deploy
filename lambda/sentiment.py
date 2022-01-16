import json
from transformers import pipeline
import os

print("Setting cache")
os.environ['TRANSFORMERS_CACHE'] = '/mnt/access/transformers'
print(os.listdir('/mnt/access/'))

print("Loading model...")
nlp = pipeline("sentiment-analysis")

def handler(event, context):
    response = {
        "statusCode": 200,
        "body": nlp(event['text'])[0]
    }
    return response