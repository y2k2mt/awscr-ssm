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
