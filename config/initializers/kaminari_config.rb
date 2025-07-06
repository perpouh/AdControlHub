# frozen_string_literal: true

Kaminari.configure do |config|
  # デフォルトの1ページあたりの件数
  config.default_per_page = 20

  # 最大1ページあたりの件数
  config.max_per_page = 100

  # ウィンドウサイズ（現在のページの前後に表示するページ数）
  config.window = 2

  # 外側ウィンドウサイズ（最初と最後のページの前後に表示するページ数）
  config.outer_window = 1

  # 左側の外側ウィンドウサイズ
  config.left = 0

  # 右側の外側ウィンドウサイズ
  config.right = 0

  # ページネーションのレンジ（最初と最後のページを表示するかどうか）
  config.page_method_name = :page

  # 1ページあたりの件数のパラメータ名
  config.param_name = :page

  # 最大ページ数（nilの場合は制限なし）
  config.max_pages = nil
end
