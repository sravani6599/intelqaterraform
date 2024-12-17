import json
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'ObjectCreated:Put':
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            metadata = {
                'FileName': object_key,
                'Bucket': bucket_name
            }
            # Add metadata to DynamoDB
            table.put_item(Item=metadata)
    return {
        'statusCode': 200,
        'body': json.dumps('Processed successfully!')
    }
