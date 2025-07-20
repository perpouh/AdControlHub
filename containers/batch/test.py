import unittest
import os
import redis
import datetime

redis_host = os.environ.get("REDIS_HOST", "localhost")
redis_port = int(os.environ.get("REDIS_PORT", "6379"))

# Redis接続
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

# 日付
today ='20250718'

# テストデータ：検索ワードと広告IDの組み合わせ
test_data = [
    ("猫グッズ", "ad001"),
    ("猫グッズ", "ad002"),
    ("猫グッズ", "ad001"),
    ("犬の服", "ad010"),
    ("犬の服", "ad010"),
    ("犬の服", "ad011"),
    ("犬の服", "ad012"),
    ("犬の服", "ad012"),
    ("犬の服", "ad012"),
]

# Redisに投入
for search_word, ad_id in test_data:
    key = f"clicklog_keys:{today}"
    # 既にキーが存在するか確認し、存在すればインクリメント、なければ1で作成
    current = r.hget(key, f"{ad_id}:{search_word}")
    if current is None:
        r.hset(key, f"{ad_id}:{search_word}", 1)
    else:
        r.hincrby(key, f"{ad_id}:{search_word}", 1)

print("Test data inserted.")
