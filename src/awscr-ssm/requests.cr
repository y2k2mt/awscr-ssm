module Awscr
  module SSM
    module Request
      abstract def action : String
      abstract def to_json : String
    end

    class GetParameterRequest
      include Request

      def initialize(@key : String, @with_decryption : Bool = false)
      end

      def action : String
        "GetParameter"
      end

      def to_json : String
        %({"Name":#{@key.to_json},"WithDecryption":#{@with_decryption}})
      end
    end

    class GetParametersByPathRequest
      include Request

      def initialize(
        @path : String,
        @max_results : Int32 = 10,
        @next_token : String? = nil,
        @recursive : Bool = true,
        @with_decryption : Bool = true,
      )
      end

      def action : String
        "GetParametersByPath"
      end

      def to_json : String
        h = {
          "Path"           => @path,
          "MaxResults"     => @max_results,
          "Recursive"      => @recursive,
          "WithDecryption" => @with_decryption,
        }
        token = @next_token
        String.build do |builder|
          builder << "{"
          builder << h.map { |k, v| "#{k.to_json}:#{v.to_json}" }.join(",")
          builder << ",\"NextToken\":#{token.to_json}" if token
          builder << "}"
        end
      end
    end

    class GetParameterHistoryRequest
      include Request

      def initialize(
        @name : String,
        @max_results : Int32 = 10,
        @next_token : String? = nil,
        @with_decryption : Bool = true,
      )
      end

      def action : String
        "GetParameterHistory"
      end

      def to_json : String
        token = @next_token
        String.build do |builder|
          builder << %({"Name":#{@name.to_json},"MaxResults":#{@max_results},"WithDecryption":#{@with_decryption})
          builder << %("NextToken":#{token.to_json}) if token
          builder << "}"
        end
      end
    end

    class DeleteParameterRequest
      include Request

      def initialize(@key : String)
      end

      def action : String
        "DeleteParameter"
      end

      def to_json : String
        %({"Name":#{@key.to_json}})
      end
    end

    class PutParameterRequest
      include Request

      def initialize(
        @key : String,
        @value : String,
        @secure : Bool,
        @description : String,
        @allowed_pattern : String,
        @key_id : String,
        @overwrite : Bool,
      )
      end

      def action : String
        "PutParameter"
      end

      def to_json : String
        String.build do |builder|
          builder << %({"Name":#{@key.to_json},"Value":#{@value.to_json})
          builder << %(,"Type":#{@secure ? "\"SecureString\"" : "\"String\""})
          builder << %(,"Overwrite":#{@overwrite})
          builder << %(,"Description":#{@description.to_json}) unless @description.empty?
          builder << %(,"AllowedPattern":#{@allowed_pattern.to_json}) unless @allowed_pattern.empty?
          builder << %(,"KeyId":#{@key_id.to_json}) unless @key_id.empty?
          builder << "}"
        end
      end
    end
  end
end
