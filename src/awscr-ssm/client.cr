module Awscr
  module SSM
    class Client
      def initialize(@region : String, @credential : Credentials = EnvCredentials.new)
        @api = Api.new(@region, @credential)
      end

      def get_parameter(key : String, with_decription : Bool = false)
        GetParameterResponse.new(
          @api.request(
            GetParameterRequest.new(key, with_decription)
          )
        ).extract
      end

      def get_parameters_by_path(path : String, max_results : Int32 = 10, next_token : (String | Nil) = nil, recursive : Bool = true, with_decription : Bool = true)
        GetParametersByPathResponse.new(
          @api.request(
            GetParametersByPathRequest.new(
              path: path,
              max_results: max_results,
              next_token: next_token,
              recursive: recursive,
              with_decription: with_decription
            )
          )
        ).extract
      end

      def delete_parameter(key : String)
        DeleteParameterResponse.new(
          @api.request(
            DeleteParameterRequest.new(key)
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
          @api.request(
            PutParameterRequest.new(key, value, secure, description, allowed_pattern, key_id, overwrite)
          )
        ).extract
      end
    end
  end
end
