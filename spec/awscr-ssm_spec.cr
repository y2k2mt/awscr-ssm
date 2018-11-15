require "spec"
require "../awscr-ssm"

describe Awscr::SSM do
  cli = Awscr::SSM::Client.new("ap-northeast-1")

  it "Plain text parameter" do
    version = cli.put_parameter("foo", "bar")
    actual = cli.get_parameter("foo")
    actual.should eq("bar")
    cli.delete_parameter("foo")
    actual = cli.get_parameter("foo")
    actual.should eq("")
  end

  it "Secure string parameter" do
    version = cli.put_parameter("foo", "bar",true)
    actual = cli.get_parameter("foo",true)
    actual.should eq("bar")
    cli.delete_parameter("foo")
    actual = cli.get_parameter("foo",true)
    actual.should eq("")
  end
end
