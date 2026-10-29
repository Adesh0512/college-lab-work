import os
import boto3

s3_client = boto3.client(
    service_name='s3',
    region_name='eu-north-1'
)

response = s3_client.upload_file(
    'upload_csv2.csv',
    os.environ.get("BUCKET", "your-bucket-name"),
    'upload_csv2.csv'
)

print(f'upload file response: {response}')