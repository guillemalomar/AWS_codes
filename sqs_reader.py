import boto3

client = boto3.client(
    'sqs',
    aws_access_key_id='XXXXX',
    aws_secret_access_key='XXXXX',
    region_name='XXXXX'
)

queue_response = client.receive_message(
    QueueUrl='https://sqs.XXXXX.amazonaws.com/XXXXX/XXXXX',
    MaxNumberOfMessages=10
)

for msg in queue_response['Messages']:
    print(msg['Body'])
