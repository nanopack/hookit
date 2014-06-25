require 'faraday'

module Hooky
  class Logvac
    
    def initialize(opts)
      @app    = opts[:app]
      @deploy = opts[:deploy]
      @token  = opts[:token]
    end

    def post(message)
      connection.post("/deploy/#{@app}") do |req|
        req.headers[:x_auth_token] = @token
        req.headers[:x_deploy_id]  = @deploy
        req.body = message
      end
    end
    alias :print :post

    def puts(message='')
      post("#{message}\n")
    end

    protected

    def connection
      @connection ||= Faraday.new(url: 'http://logvac.admin.pagodabox.io:6361') do |faraday|
        faraday.adapter :excon
      end
    end

  end
end