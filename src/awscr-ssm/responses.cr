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
          parameters: data["Parameters"].as_a.map do |p|
            Awscr::SSM::Parameter.new(
              arn:                p["ARN"]?.try(&.as_s?),
              last_modified_date: p["LastModifiedDate"]?.try { |d| Time.unix(d.as_f.to_i64) },
              name:               p["Name"].as_s,
              type:               p["Type"].as_s,
              value:              p["Value"].as_s,
              version:            p["Version"].as_i64
            )
          end,
          next_token: data["NextToken"]?.try(&.as_s?)
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
          parameters: data["Parameters"].as_a.map do |p|
            Awscr::SSM::ParameterHistory.new(
              allowed_pattern:    p["AllowedPattern"]?.try(&.as_s?),
              description:        p["Description"]?.try(&.as_s?),
              key_id:             p["KeyId"]?.try(&.as_s?),
              labels:             p["Labels"]?.try(&.as_s?),
              last_modified_date: p["LastModifiedDate"]?.try { |d| Time.unix(d.as_f.to_i64) },
              last_modified_user: p["LastModifiedUser"]?.try(&.as_s?),
              name:               p["Name"].as_s,
              type:               p["Type"].as_s,
              value:              p["Value"].as_s,
              version:            p["Version"].as_i64
            )
          end,
          next_token: data["NextToken"]?.try(&.as_s?)
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
