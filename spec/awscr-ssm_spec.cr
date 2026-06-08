require "spec"
require "../src/awscr-ssm"

describe Awscr::SSM do
  provider = Aws::Credentials::Providers.new([
    Aws::Credentials::SimpleCredentials.new("test", "test"),
  ] of Aws::Credentials::Provider)
  cli = Awscr::SSM::Client.new("ap-northeast-1", "http://localhost:4566", provider)

  it "Plain text parameter" do
    cli.put_parameter("foo", "bar")
    actual = cli.get_parameter("foo")
    actual.should eq("bar")
    cli.delete_parameter("foo")
  end

  it "Plain text parameter without result" do
    begin
      cli.get_parameter("foo")
    rescue e
      e.message.should eq("SSM error: {\"__type\": \"ParameterNotFound\", \"message\": \"Parameter foo not found.\"}")
    end
  end

  it "Secure string parameter" do
    cli.put_parameter("foo", "bar", true)
    actual = cli.get_parameter("foo", true)
    actual.should eq("bar")
    cli.delete_parameter("foo")
  end

  it "Secure string parameter" do
    begin
      cli.get_parameter("foo", true)
    rescue e
      e.message.should eq("SSM error: {\"__type\": \"ParameterNotFound\", \"message\": \"Parameter foo not found.\"}")
    end
  end

  it "List string parameters" do
    cli.put_parameter("/foo/bar", "hoge", true)
    cli.put_parameter("/foo/baz", "fuga", true)
    actual = cli.get_parameters_by_path("/foo")
    actual[:parameters][0].value.should eq("hoge")
    actual[:parameters][1].value.should eq("fuga")
  end

  it "List string parameters without result" do
    actual = cli.get_parameters_by_path("/bar")
    actual[:parameters].empty?.should eq(true)
    # actual[:next_token].empty?.should eq(true)
  end

  it "String parameter histories" do
    cli.put_parameter("/foo/bar/baz", "hoge", true)
    cli.put_parameter("/foo/bar/baz", "fuga", true)
    actual = cli.get_parameter_history("/foo/bar/baz")
    actual[:parameters][0].value.should eq("hoge")
    actual[:parameters][1].value.should eq("fuga")
    actual[:parameters][1].version.should eq(2)
  end

  it "String parameter histories without result" do
    begin
      cli.get_parameter_history("/bar")
    rescue e
      e.message.should eq("SSM error: {\"__type\": \"ParameterNotFound\", \"message\": \"Parameter /bar not found.\"}")
    end
  end

  # cli.delete_parameter("foo")
  # cli.delete_parameter("/foo/bar")
  # cli.delete_parameter("/foo/baz")
  # cli.delete_parameter("/foo/bar/baz")
end
