module Awscr
  module SSM
    class Client
      def initialize(@region : String, @credential : Credentials = Awscr::SSM.default_credentials)
        @api = Api.new(@region, @credential)
      end

      def get_parameter(key : String, with_decryption : Bool = false) : String
        GetParameterResponse.new(
          @api.request(GetParameterRequest.new(key, with_decryption))
        ).extract
      end

      def get_parameters_by_path(
        path : String,
        max_results : Int32 = 10,
        next_token : String? = nil,
        recursive : Bool = true,
        with_decryption : Bool = true
      ) : ParameterResult
        GetParametersByPathResponse.new(
          @api.request(
            GetParametersByPathRequest.new(
              path: path,
              max_results: max_results,
              next_token: next_token,
              recursive: recursive,
              with_decryption: with_decryption
            )
          )
        ).extract
      end

      def get_parameter_history(
        name : String,
        max_results : Int32 = 10,
        next_token : String? = nil,
        with_decryption : Bool = true
      ) : ParameterHistoryResult
        GetParameterHistoryResponse.new(
          @api.request(
            GetParameterHistoryRequest.new(
              name: name,
              max_results: max_results,
              next_token: next_token,
              with_decryption: with_decryption
            )
          )
        ).extract
      end

      def delete_parameter(key : String) : Void
        DeleteParameterResponse.new(
          @api.request(DeleteParameterRequest.new(key))
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
      ) : Int32
        PutParameterResponse.new(
          @api.request(
            PutParameterRequest.new(key, value, secure, description, allowed_pattern, key_id, overwrite)
          )
        ).extract
      end
    end
  end
end
