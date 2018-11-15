require "xml"
require "awscr-signer"

module Awscr
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

  module SSM
    class Client
      def initialize(@region : String, @credential : Credentials = EnvCredentials.new)
      end

      def get_parameter(key : String, with_decription : Bool = false)
        GetParameterResponse.new(SSMApi.new(@region, @credential).request(GetParameterRequest.new(key, with_decription))).extract
      end

      def put_parameter(
        key : String,
        value : String,
        encrypt : Bool = false,
        description : String = "",
        allowed_pattern : String = "",
        key_id : String = "",
        overwrite : Bool = true
      )
        PutParameterResponse.new(SSMApi.new(@region, @credential).request(PutParameterRequest.new(key, value, encrypt, description, allowed_pattern, key_id, overwrite))).extract
      end
    end

    module Request
      abstract def to_parameters : Hash(String, String)
      abstract def method : String
    end

    class GetParameterRequest
      include Request

      def initialize(
        @key : String,
        @with_decription : Bool = true
      )
      end

      def method : String
        "POST"
      end

      def to_parameters : Hash(String, String)
        {"Action" => "GetParameter", "Name" => @key, "WithDecryption" => @with_decription.to_s}
      end
    end

    class PutParameterRequest
      include Request

      def initialize(
        @key : String,
        @value : String,
        @encrypt : Bool,
        @description : String,
        @allowed_pattern : String,
        @key_id : String,
        @overwrite : Bool
      )
      end

      def method : String
        "POST"
      end

      def to_parameters : Hash(String, String)
	      h = {"Action" => "PutParameter", "Name" => @key, "Value" => @value, "Type" => "String", "Overwrite" => @overwrite.to_s, "AllowedPattern" => @allowed_pattern, "Description" => @description}
        if @encrypt
          h["Type"] = "SecureString"
        end
	if ! @key_id.empty?
          h["KeyId"] = @key_id
        end
        h
      end
    end

    module Response(T)
      abstract def extract : T
    end

    class GetParameterResponse
      include Response(String)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : String
        xml = XML.new(@response.body)
        xml.string("//GetParameterResult/Parameter/Value")
      end
    end

    class PutParameterResponse
      include Response(String)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Int32
        xml = XML.new(@response.body)
	xml.string("//PutParameterResult/Version").to_i
      end
    end

    class SSMApi
      def initialize(@region : String, @credential : Credentials)
      end

      def uri
        URI.parse("https://ssm.#{@region}.amazonaws.com")
      end

      def client
        client = HTTP::Client.new(uri)
        client.before_request do |request|
          signer = Awscr::Signer::Signers::V4.new("ssm", @region, @credential.key, @credential.secret)
          signer.sign(request)
        end
        client
      end

      def request(r : Request)
        r.to_parameters
        case r.method
        when "POST"
          client.post(path: "/", form: r.to_parameters)
        else
          HTTP::Client::Response.new(415)
        end
      end
    end

    class XML
      # :nodoc:
      struct NamespacedNode
        def initialize(@node : ::XML::Node)
        end

        def string(name)
          @node.xpath("string(#{build_path(name)})", namespaces).as(String)
        end

        def array(query)
          @node.xpath(build_path(query), namespaces).as(::XML::NodeSet).each do |node|
            yield NamespacedNode.new(node)
          end
        end

        # :nodoc:
        private def build_path(path)
          anywhere = false
          if path.starts_with?("//")
            anywhere = true
            path = path[2..-1]
          end

          parts = path.split("/").map do |part|
            "#{namespace}#{part}"
          end

          parts = (["/"] + parts) if anywhere

          (parts).join("/")
        end

        # :nodoc:
        private def namespace
          if namespaces.empty?
            ""
          else
            "#{namespaces.keys.first}:"
          end
        end

        # :nodoc:
        private def namespaces
          @node.root.not_nil!.namespaces
        end
      end

      def initialize(xml : String)
        @xml = NamespacedNode.new(::XML.parse(xml))
      end

      # :nodoc:
      forward_missing_to @xml
    end
  end
end
