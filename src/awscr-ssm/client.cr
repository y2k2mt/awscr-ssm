module Awscr
  module SSM
    class Client
      def initialize(@region : String, @credential : Credentials = EnvCredentials.new)
      end

      def get_parameter(key : String, with_decription : Bool = false)
        GetParameterResponse.new(
          Api.new(@region, @credential).request(
            GetParameterRequest.new(key, with_decription)
          )
        ).extract
      end

      def put_parameter(
        key : String,
        value : String,
        secure : Bool = false,
        description : String = "",
        allowed_pattern : String = "",
        key_id : String = "",
        overwrite : Bool = true
      )
        PutParameterResponse.new(
          Api.new(@region, @credential).request(
            PutParameterRequest.new(key, value, secure, description, allowed_pattern, key_id, overwrite)
          )
        ).extract
      end
    end
  end
end
