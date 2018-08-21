require "spec"
require "../awscr-ssm"

describe Awscr::SSM do
  it "Plain text parameter" do
    version = Awscr::SSM::Client.new("ap-northeast-1").put_parameter("foo", "bar")
    actual = Awscr::SSM::Client.new("ap-northeast-1").get_parameter("foo")
    actual.should eq("bar")
  end
end
