require "awscr-signer"
require "json"

module Awscr
  module SSM
    class Api
      def initialize(@region : String, @credential : Credentials)
      end

      def uri
        URI.parse("https://ssm.#{@region}.amazonaws.com")
      end

      def client
        client = HTTP::Client.new(uri)
        client.before_request do |request|
          signer = Awscr::Signer::Signers::V4.new("ssm", @region, @credential.key, @credential.secret)
          if token = @credential.session_token
            request.headers["X-Amz-Security-Token"] = token
          end
          signer.sign(request)
        end
        client
      end

      def request(r : Request)
        client.post("/",
          headers: HTTP::Headers{
            "Content-Type" => "application/x-amz-json-1.1",
            "X-Amz-Target" => "AmazonSSM.#{r.action}"
          },
          body: r.to_json
        )
      end
    end
  end
end
