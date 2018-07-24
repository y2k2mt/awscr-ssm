require "spec"
require "../ssm"

describe Awscr::SSM do
  it "Plain text parameter" do
    expected = "bar"
    version = Awscr::SSM::Client.new("ap-northeast-1").put_parameter("foo", expected)
    actual = Awscr::SSM::Client.new("ap-northeast-1").get_parameter("foo")
    actual.should eq(expected)
  end
  it "Secret text parameter" do
    expected = "df6g7h9j[0kl$=;]="
    version = Awscr::SSM::Client.new("ap-northeast-1").put_parameter("hoge", expected, true)
    actual = Awscr::SSM::Client.new("ap-northeast-1").get_parameter("hoge",true)
    actual.should eq(expected)
  end
end
