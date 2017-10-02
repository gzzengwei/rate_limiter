require 'rails_helper'

RSpec.describe RateLimit do
  let(:app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['ok']] } }
  let(:rate_limit) do
    described_class.new(
      app,
      rate_limit: 3,
      rate_period: 5,
      controllers: controllers
    )
  end
  let(:request) { Rack::MockRequest.new(rate_limit) }


  context 'for rate limited controller' do
    let(:controllers) { ['home'] }

    it 'response with "200"' do
      last_response = request.get('/home/index', 'CONTENT_TYPE' => 'text/plain')
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('ok')
    end

    it 'request 3 times return response with "200"' do
      last_response = (1..3).reduce do
        request.get('/home/index', 'Content_Type' => 'text/plain')
      end
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('ok')
    end

    it 'request 4 times return response with "429"' do
      allow(rate_limit).to receive_messages(expired_in: 3)

      last_response = (1..4).reduce do
        last_response = request.get('/home/index', 'Content_Type' => 'text/plain')
      end
      expect(last_response.status).to eq(429)
      expect(last_response.body).to eq('Rate limit exceeded. Try again in 3 seconds')
    end
  end

  context 'for not rate limited controllers' do
    let(:controllers) { ['others'] }

    it 'request 4 times return response with "200"' do
      last_response = (1..4).reduce do
        last_response = request.get('/home/index', 'Content_Type' => 'text/plain')
      end
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('ok')
    end
  end
end

