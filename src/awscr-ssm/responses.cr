require "./model"

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
        xml = XML.new(@response.body)
        xml.string("//GetParameterResult/Parameter/Value")
      end
    end

    class GetParametersByPathResponse
      include Response(Awscr::SSM::ParameterResult)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Awscr::SSM::ParameterResult
        xml = XML.new(@response.body)
        {
          parameters: xml.array("//GetParametersByPathResponse/GetParametersByPathResult/Parameters/member") do |node|
            Awscr::SSM::Parameter.new(
              arn: node.string("ARN"),
              last_modified_date: Time.parse_rfc3339(node.string("LastModifiedDate")),
              value: node.string("Value"),
              version: node.string("Version").to_i64,
              name: node.string("Name"),
              type: node.string("Type")
            )
          end,
          next_token: xml.string("//GetParametersByPathResponse/GetParametersByPathResult/NextToken"),
        }
      end
    end

    class GetParameterHistoryResponse
      include Response(Awscr::SSM::ParameterHistoryResult)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Awscr::SSM::ParameterHistoryResult
        xml = XML.new(@response.body)
        {
          parameters: xml.array("//GetParameterHistoryResponse/GetParameterHistoryResult/Parameters/member") do |node|
            Awscr::SSM::ParameterHistory.new(
              allowed_pattern: node.string("AllowedPattern"),
              description: node.string("Description"),
              key_id: node.string("KeyId"),
              labels: node.string("Labels"),
              last_modified_date: Time.parse_rfc3339(node.string("LastModifiedDate")),
              last_modified_user: node.string("LastModifiedUser"),
              name: node.string("Name"),
              type: node.string("Type"),
              value: node.string("Value"),
              version: node.string("Version").to_i64,
            )
          end,
          next_token: xml.string("//GetParameterHistoryResponse/GetParameterHistoryResult/NextToken"),
        }
      end
    end

    class DeleteParameterResponse
      include Response(Void)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract
      end
    end

    class PutParameterResponse
      include Response(Int32)

      def initialize(@response : HTTP::Client::Response)
      end

      def extract : Int32
        xml = XML.new(@response.body)
        xml.string("//PutParameterResult/Version").to_i
      end
    end
  end
end
