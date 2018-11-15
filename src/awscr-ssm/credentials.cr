module Awscr
  module SSM
    module Credentials
      abstract def key : String
      abstract def secret : String
    end

    struct SimpleCredentials
      include Credentials

      def initialize(@key : String, @secret : String)
      end

      def key
        @key
      end

      def secret
        @secret
      end
    end

    struct EnvCredentials
      include Credentials

      def initialize
      end

      def key
        ENV["AWS_ACCESS_KEY_ID"]
      end

      def secret
        ENV["AWS_SECRET_ACCESS_KEY"]
      end
    end
  end
end
