module Awscr
  module SSM
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
        {
          "Action"         => "GetParameter",
          "Name"           => @key,
          "WithDecryption" => @with_decription.to_s,
        }
      end
    end

    class GetParametersByPathRequest
      include Request

      def initialize(
        @path : String,
        @max_results : Int32 = 10,
        @next_token : (String | Nil) = nil,
        @recursive : Bool = true,
        @with_decription : Bool = true
      )
      end

      def method : String
        "POST"
      end

      def to_parameters : Hash(String, String)
        h = {
          "Action"         => "GetParametersByPath",
          "Path"           => @path,
          "MaxResults"     => @max_results.to_s,
          "Recursive"      => @recursive.to_s,
          "WithDecryption" => @with_decription.to_s,
        }
        @next_token.try { |n| h["NextToken"] = n }
        h
      end
    end

    class GetParameterHistoryRequest
      include Request

      def initialize(
        @name : String,
        @max_results : Int32 = 10,
        @next_token : (String | Nil) = nil,
        @with_decription : Bool = true
      )
      end

      def method : String
        "POST"
      end

      def to_parameters : Hash(String, String)
        h = {
          "Action"         => "GetParameterHistory",
          "Name"           => @name,
          "MaxResults"     => @max_results.to_s,
          "WithDecryption" => @with_decription.to_s,
        }
        @next_token.try { |n| h["NextToken"] = n }
        h
      end
    end

    class DeleteParameterRequest
      include Request

      def initialize(
        @key : String
      )
      end

      def method : String
        "POST"
      end

      def to_parameters : Hash(String, String)
        {
          "Action" => "DeleteParameter",
          "Name"   => @key,
        }
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
        @overwrite : Bool
      )
      end

      def method : String
        "POST"
      end

      def to_parameters : Hash(String, String)
        h = {
          "Action"         => "PutParameter",
          "Name"           => @key,
          "Value"          => @value,
          "Type"           => "String",
          "Overwrite"      => @overwrite.to_s,
          "AllowedPattern" => @allowed_pattern,
          "Description"    => @description,
        }
        if @secure
          h["Type"] = "SecureString"
        end
        if !@key_id.empty?
          h["KeyId"] = @key_id
        end
        h
      end
    end
  end
end
