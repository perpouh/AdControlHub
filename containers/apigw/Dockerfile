FROM ruby:3.2-alpine
WORKDIR /app
COPY . /app

# 追加: ビルドに必要なパッケージをインストール
RUN apk add --no-cache build-base linux-headers

RUN gem install bundler && bundle install
CMD ["ruby", "app.rb"] 