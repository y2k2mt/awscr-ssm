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

  it "List string parameters" do
    cli.put_parameter("/foo/bar", "hoge",true)
    cli.put_parameter("/foo/baz", "fuga",true)
    actual = cli.get_parameters_by_path("/foo")
    actual[0].value.should eq("hoge")
    actual[1].value.should eq("fuga")
    actual = cli.get_parameters_by_path("/bar")
    actual.empty?.should eq(true)
  end

  cli.delete_parameter("foo")
  cli.delete_parameter("/foo/bar")
  cli.delete_parameter("/foo/baz")

end
