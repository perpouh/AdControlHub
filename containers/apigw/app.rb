require 'sinatra'
require 'json'
require 'httparty'

set :bind, '0.0.0.0'

post '/register' do
  content_type :json
  req = JSON.parse(request.body.read) rescue {}
  email = req['email']
  halt 400, { error: 'メールアドレスが必要です' }.to_json unless email

  # Lambda(Python)のエンドポイントに転送（仮: http://lambda:5000/register）
  lambda_url = ENV['LAMBDA_URL'] || 'http://lambda:5000/register'
  response = HTTParty.post(lambda_url, body: { email: email }.to_json, headers: { 'Content-Type' => 'application/json' })

  status response.code
  response.body
end

post '/verify' do
  content_type :json
  req = JSON.parse(request.body.read) rescue {}
  email = req['email']
  otp = req['otp']
  halt 400, { error: 'メールアドレスとOTPが必要です' }.to_json unless email && otp

  lambda_url = ENV['LAMBDA_VERIFY_URL'] || 'http://lambda:5000/verify'
  response = HTTParty.post(lambda_url, body: { email: email, otp: otp }.to_json, headers: { 'Content-Type' => 'application/json' })

  status response.code
  response.body
end 