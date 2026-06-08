require "./model"
require "json"

module Awscr
  module SSM
    module Response(T)
      abstract def extract : T
    end

    class GetParameterResponse
      include Response(String)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : String
        raise "SSM error: #{@response.body}" unless @response.success?
        JSON.parse(@response.body)["Parameter"]["Value"].as_s
      end
    end

    class GetParametersByPathResponse
      include Response(Awscr::SSM::ParameterResult)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Awscr::SSM::ParameterResult
        raise "SSM error: #{@response.body}" unless @response.success?
        data = JSON.parse(@response.body)
        {
          parameters: data["Parameters"].as_a.map do |params|
            Awscr::SSM::Parameter.new(
              arn: params["ARN"]?.try(&.as_s?),
              last_modified_date: params["LastModifiedDate"]?.try { |date| Time.unix(date.as_f.to_i64) },
              name: params["Name"].as_s,
              type: params["Type"].as_s,
              value: params["Value"].as_s,
              version: params["Version"].as_i64
            )
          end,
          next_token: data["NextToken"]?.try(&.as_s?),
        }
      end
    end

    class GetParameterHistoryResponse
      include Response(Awscr::SSM::ParameterHistoryResult)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Awscr::SSM::ParameterHistoryResult
        raise "SSM error: #{@response.body}" unless @response.success?
        data = JSON.parse(@response.body)
        {
          parameters: data["Parameters"].as_a.map do |params|
            Awscr::SSM::ParameterHistory.new(
              allowed_pattern: params["AllowedPattern"]?.try(&.as_s?),
              description: params["Description"]?.try(&.as_s?),
              key_id: params["KeyId"]?.try(&.as_s?),
              labels: params["Labels"]?.try(&.as_s?),
              last_modified_date: params["LastModifiedDate"]?.try { |date| Time.unix(date.as_f.to_i64) },
              last_modified_user: params["LastModifiedUser"]?.try(&.as_s?),
              name: params["Name"].as_s,
              type: params["Type"].as_s,
              value: params["Value"].as_s,
              version: params["Version"].as_i64
            )
          end,
          next_token: data["NextToken"]?.try(&.as_s?),
        }
      end
    end

    class DeleteParameterResponse
      include Response(Void)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Void
        raise "SSM error: #{@response.body}" unless @response.success?
      end
    end

    class PutParameterResponse
      include Response(Int32)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Int32
        raise "SSM error: #{@response.body}" unless @response.success?
        JSON.parse(@response.body)["Version"].as_i
      end
    end
  end
end
