import unittest
import os
import redis
import datetime
from main import analyze

redis_host = os.environ.get("REDIS_HOST", "localhost")
redis_port = int(os.environ.get("REDIS_PORT", "6379"))

# Redis接続
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

def seed():
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

def test():
    # INSERT_YOUR_CODE
    import psycopg2

    # PostgreSQL接続設定（環境変数から読み取り）
    pg_host = os.environ.get("POSTGRES_HOST", "localhost")
    pg_port = os.environ.get("POSTGRES_PORT", "5432")
    pg_database = os.environ.get("POSTGRES_DB", "adcontrolhub_development")
    pg_user = os.environ.get("POSTGRES_USER", "postgres")
    pg_password = os.environ.get("POSTGRES_PASSWORD", "")

    # 期待される集計結果
    # ad001:猫グッズ → 2回
    # ad002:猫グッズ → 1回
    # ad010:犬の服 → 2回
    # ad011:犬の服 → 1回
    # ad012:犬の服 → 3回
    expected = {
        ("ad001", "猫グッズ"): 2,
        ("ad002", "猫グッズ"): 1,
        ("ad010", "犬の服"): 2,
        ("ad011", "犬の服"): 1,
        ("ad012", "犬の服"): 3,
    }

    # PostgreSQLに接続してデータを取得
    conn = psycopg2.connect(
        host=pg_host,
        port=pg_port,
        database=pg_database,
        user=pg_user,
        password=pg_password
    )
    cursor = conn.cursor()
    cursor.execute("""
        SELECT advertisement_id, search_word, click_count
        FROM advertisement_analytics
        WHERE target_date = %s
    """, ("20250718",))
    rows = cursor.fetchall()
    conn.close()

    # 実際のデータを辞書に格納
    actual = {}
    for ad_id, search_word, click_count in rows:
        actual[(ad_id, search_word)] = click_count

    # 期待値と実際の値を比較
    for key, value in expected.items():
        if actual.get(key) != value:
            print(f"❌ 不一致: {key} 期待値={value} 実際値={actual.get(key)}")
        else:
            print(f"✅ 一致: {key} = {value}")

    # 余分なデータがないかもチェック
    for key in actual.keys():
        if key not in expected:
            print(f"⚠️  予期しないデータ: {key} = {actual[key]}")

    print("テスト完了")

if __name__ == "__main__":
    seed()
    analyze("20250718")
    test()