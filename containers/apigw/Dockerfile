FROM ruby:3.2-alpine
WORKDIR /app
COPY . /app
RUN gem install bundler && bundle install
CMD ["ruby", "app.rb"] 