import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('car_prices')

#HELLLLLLLLLLLLLLLLO

def lambda_handler(event, context):
    try:
        # Pobieramy tylko jeden rekord, żeby odczytać nazwy kolumn
        response = table.scan(Limit=1)
        items = response.get('Items', [])
        
        if not items:
            return build_response(200, [])
            
        # Wyciągamy wszystkie klucze z pobranego rekordu
        all_columns = list(items[0].keys())
        
        # Odrzucamy kolumnę 'date' oraz ewentualne ukryte klucze techniczne, jeśli jakieś masz
        columns_to_exclude = ['date']
        
        # Filtrujemy i sortujemy alfabetycznie
        models = [col for col in all_columns if col not in columns_to_exclude]
        models.sort()
        
        return build_response(200, models)
        
    except Exception as e:
        print(f"Error fetching models: {e}")
        return build_response(500, {'error': 'Wystąpił błąd po stronie serwera'})

def build_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        },
        'body': json.dumps(body)
    }