import os
import redis
import sys
from datetime import datetime
from collections import defaultdict
import psycopg2
from psycopg2.extras import execute_values

def handler(event, context):
    # Lambda用エントリーポイント
    arg = event.get("arg", "")
    result = analyze(arg)
    return {"result": result}

def analyze(arg):
    redis_host = os.environ.get("REDIS_HOST", "localhost")
    redis_port = os.environ.get("REDIS_PORT", "6379")

    # PostgreSQL接続設定（環境変数から読み取り）
    pg_host = os.environ.get("POSTGRES_HOST", "localhost")
    pg_port = os.environ.get("POSTGRES_PORT", "5432")
    pg_database = os.environ.get("POSTGRES_DB", "adcontrolhub_development")
    pg_user = os.environ.get("POSTGRES_USER", "postgres")
    pg_password = os.environ.get("POSTGRES_PASSWORD", "")

    target_date = arg

    r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

    # PostgreSQLに接続
    try:
        conn = psycopg2.connect(
            host=pg_host,
            port=pg_port,
            database=pg_database,
            user=pg_user,
            password=pg_password
        )
        cursor = conn.cursor()
        print("✅ PostgreSQLに接続しました")
    except Exception as e:
        print(f"❌ PostgreSQL接続エラー: {e}")
        sys.exit(1)

    # 仮想ログキー一覧を取得して処理
    key_set_name = f"clicklog_keys:{target_date}"

    # ハッシュ形式のデータを取得
    log_data = r.hgetall(key_set_name)

    # 集計用の辞書
    click_summary = defaultdict(int)

    for key, count in log_data.items():
        print(f"[処理] {key} = {count}")
        
        # データを解析（広告ID:検索ワードの形式を想定）
        try:
            parts = key.split(':')
            if len(parts) >= 2:
                ad_id = parts[0]
                search_word = parts[1]
                # 広告IDと検索ワードの組み合わせでカウント
                click_summary[f"{ad_id}:{search_word}"] += int(count)
            else:
                print(f"⚠️  データ形式が不正です: {key}")
        except Exception as e:
            print(f"⚠️  データ解析エラー: {e}")

    # PostgreSQLに集計結果を登録
    if click_summary:
        try:
            # バッチ挿入用のデータを準備
            insert_data = []
            for key, count in click_summary.items():
                ad_id, search_word = key.split(':', 1)
                insert_data.append((ad_id, target_date, search_word, count))
            
            # advertisement_analyticsテーブルに挿入
            insert_query = """
                INSERT INTO advertisement_analytics 
                (advertisement_id, target_date, search_word, click_count) 
                VALUES %s
            """
            
            execute_values(cursor, insert_query, insert_data)
            conn.commit()
            
            print(f"✅ {len(insert_data)}件の集計データをPostgreSQLに登録しました")
            
        except Exception as e:
            print(f"❌ PostgreSQL登録エラー: {e}")
            conn.rollback()
    else:
        print("ℹ️  登録するデータがありません")


    # データを削除
    r.delete(key_set_name)
    # 接続を閉じる
    cursor.close()
    conn.close()

    print(f"✅ 日次バッチ完了 (対象日: {target_date})")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("❌ エラー: 日付を指定してください")
        print("使用方法: python main.py YYYYMMDD")
        print("例: python main.py 20250714")
        sys.exit(1)

    target_date = sys.argv[1]
    analyze(target_date)