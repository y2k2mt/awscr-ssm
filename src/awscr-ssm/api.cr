require "awscr-signer"
require "json"

module Awscr
  module SSM
    class Api
      def initialize(@region : String, @credential_provider : Aws::Credentials::Provider = Awscr::SSM::Credentials.default_provider)
        initialize(region, credential, "https://ssm.#{region}.amazonaws.com")
      end

      def initialize(@region : String, @credential_provider : Aws::Credentials::Provider, @internal_uri : String)
      end

      def uri
        URI.parse(@internal_uri)
      end

      def client
        client = HTTP::Client.new(uri)
        client.before_request do |request|
          credential = @credential_provider.credentials
          signer = Awscr::Signer::Signers::V4.new("ssm", @region, credential.access_key_id, credential.secret_access_key)
          if token = credential.session_token
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
            "X-Amz-Target" => "AmazonSSM.#{r.action}",
          },
          body: r.to_json
        )
      end
    end
  end
end
