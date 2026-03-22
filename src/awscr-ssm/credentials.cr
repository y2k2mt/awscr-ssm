require "http/client"
require "json"

module Awscr
  module SSM
    module Credentials
      abstract def key : String
      abstract def secret : String

      def session_token : String?
        nil
      end
    end

    # Explicit key/secret, optionally with a session token
    struct SimpleCredentials
      include Credentials

      def initialize(@key : String, @secret : String, @session_token : String? = nil)
      end

      def key : String
        @key
      end

      def secret : String
        @secret
      end

      def session_token : String?
        @session_token
      end
    end

    # Reads AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and optionally
    # AWS_SESSION_TOKEN from the environment
    struct EnvCredentials
      include Credentials

      def initialize
        missing = [] of String
        missing << "AWS_ACCESS_KEY_ID" unless ENV.has_key?("AWS_ACCESS_KEY_ID")
        missing << "AWS_SECRET_ACCESS_KEY" unless ENV.has_key?("AWS_SECRET_ACCESS_KEY")
        unless missing.empty?
          raise "Missing required environment variables: #{missing.join(", ")}"
        end
      end

      def key : String
        ENV["AWS_ACCESS_KEY_ID"]
      end

      def secret : String
        ENV["AWS_SECRET_ACCESS_KEY"]
      end

      def session_token : String?
        ENV["AWS_SESSION_TOKEN"]?
      end
    end

    # Fetches credentials from the EC2 Instance Metadata Service (IMDSv2)
    struct InstanceCredentials
      include Credentials

      METADATA_HOST    = "169.254.169.254"
      TOKEN_TTL        = "21600"
      TOKEN_PATH       = "/latest/api/token"
      CREDENTIALS_PATH = "/latest/meta-data/iam/security-credentials/"

      @key : String
      @secret : String
      @session_token : String?

      def initialize
        @key, @secret, @session_token = fetch
      end

      def key : String
        @key
      end

      def secret : String
        @secret
      end

      def session_token : String?
        @session_token
      end

      private def fetch : {String, String, String?}
        # Step 1: get IMDSv2 token
        client = HTTP::Client.new(METADATA_HOST)
        resp = client.put(TOKEN_PATH, headers: HTTP::Headers{
          "X-aws-ec2-metadata-token-ttl-seconds" => TOKEN_TTL
        })
        raise "IMDSv2 token request failed: #{resp.status_code}" unless resp.success?
        imds_token = resp.body.strip

        headers = HTTP::Headers{"X-aws-ec2-metadata-token" => imds_token}

        # Step 2: get role name
        resp = client.get(CREDENTIALS_PATH, headers: headers)
        raise "Could not retrieve IAM role from IMDS: #{resp.status_code}" unless resp.success?
        role = resp.body.strip.lines.first?.try(&.strip)
        raise "No IAM role attached to this instance" if role.nil? || role.empty?

        # Step 3: get credentials for role
        resp = client.get("#{CREDENTIALS_PATH}#{role}", headers: headers)
        raise "Could not retrieve credentials for role '#{role}': #{resp.status_code}" unless resp.success?

        data = JSON.parse(resp.body)
        key    = data["AccessKeyId"].as_s
        secret = data["SecretAccessKey"].as_s
        token  = data["Token"].as_s?

        {key, secret, token}
      ensure
        client.try(&.close)
      end
    end

    # Resolves credentials using the standard AWS credential chain:
    # 1. Explicit env vars (AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY)
    # 2. EC2 instance metadata (IMDSv2)
    def self.default_credentials : Credentials
      if ENV.has_key?("AWS_ACCESS_KEY_ID") && ENV.has_key?("AWS_SECRET_ACCESS_KEY")
        EnvCredentials.new
      else
        InstanceCredentials.new
      end
    rescue ex
      raise "Could not resolve AWS credentials from environment or instance metadata: #{ex.message}"
    end
  end
end
