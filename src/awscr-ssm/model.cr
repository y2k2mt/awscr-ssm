module Awscr::SSM
  alias ParameterResult = NamedTuple(parameters: Array(Parameter), next_token: String)

  struct Parameter
    getter arn, last_modified_date, name, selector, type, value, version

    def initialize(
      @arn : (String | Nil) = nil,
      @last_modified_date : (Time | Nil) = nil,
      @name : String = "",
      @selector : (String | Nil) = nil,
      @type : String = "",
      @value : String = "",
      @version : Int64 = 0.to_i64
    )
    end
  end
end
