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

  alias ParameterHistoryResult = NamedTuple(parameters: Array(ParameterHistory), next_token: String)

  struct ParameterHistory
    getter allowed_pattern,description,key_id,labels,last_modified_user, last_modified_date, name, type, value, version

    def initialize(
      @allowed_pattern : (String | Nil) = nil,
      @description : (String | Nil) = nil,
      @key_id : (String | Nil) = nil,
      @labels : (String | Nil) = nil,
      @last_modified_date : (Time | Nil) = nil,
      @last_modified_user : (String | Nil) = nil,
      @name : String = "",
      @type : String = "",
      @value : String = "",
      @version : Int64 = 0.to_i64
    )
    end
  end
end
