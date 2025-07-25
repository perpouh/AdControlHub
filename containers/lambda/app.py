from flask import Flask, request, jsonify
from email_validator import validate_email, EmailNotValidError
import random
import string
import boto3
import os
from datetime import datetime, timedelta
import requests

app = Flask(__name__)

OTP_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
OTP_LENGTH = 6
DYNAMO_TABLE = os.environ.get('DYNAMO_TABLE', 'user_otps')
MAILHOG_URL = os.environ.get('MAILHOG_URL', 'http://mailhog:8025')

# DynamoDBクライアント（ローカル用設定）
dynamodb = boto3.resource('dynamodb', endpoint_url=os.environ.get('DYNAMO_ENDPOINT', 'http://dynamodb-local:8000'), region_name='ap-northeast-1', aws_access_key_id='dummy', aws_secret_access_key='dummy')

def generate_otp():
    return ''.join(random.choices(OTP_CHARS, k=OTP_LENGTH))

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    try:
        validate_email(email)
    except EmailNotValidError:
        return jsonify({'error': 'メールアドレス形式が不正です'}), 400

    otp = generate_otp()
    # DynamoDB保存（TTL: 24h）
    table = dynamodb.Table(DYNAMO_TABLE)
    ttl = int((datetime.utcnow() + timedelta(hours=24)).timestamp())
    table.put_item(Item={
        'email': email,
        'otp': otp,
        'ttl': ttl
    })
    # MailHogでメール送信（仮: printで代用）
    print(f"[Mail] {email} にOTP: {otp} を送信")
    # 本来はMailHogのAPIやSMTPで送信
    return jsonify({'message': 'OTPを送信しました'}), 200

@app.route('/verify', methods=['POST'])
def verify():
    data = request.get_json()
    email = data.get('email')
    otp = data.get('otp')
    if not email or not otp:
        return jsonify({'error': 'メールアドレスとOTPが必要です'}), 400
    table = dynamodb.Table(DYNAMO_TABLE)
    item = table.get_item(Key={'email': email}).get('Item')
    if not item or item.get('otp') != otp:
        return jsonify({'error': '認証コードが正しくありません'}), 401
    # 認証成功時はレコード削除（ワンタイム）
    table.delete_item(Key={'email': email})
    return jsonify({'message': '認証成功'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 