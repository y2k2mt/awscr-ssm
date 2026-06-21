# awscr-ssm

A Crystal shard for AWS Systems Manager Parameter Store.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  awscr-ssm:
    github: y2k2mt/awscr-ssm
```

## Supported Crystal version

1.0+

## Credentials

Credentials are resolved automatically using [y2k2mt/aws-credentials.cr](https://github.com/y2k2mt/aws-credentials.cr)'s credential provider chain:
You can also provide credentials explicitly:

```crystal
require "awscr-ssm"
require "aws-credentials"

provider = AWS::Credentials::SimpleCredentials.new(
   access_key_id: "AK...",
   secret_access_key: "SECRET...",
)
client = Awscr::SSM::Client.new("ap-northeast-1", provider)
```

## Quick Start

```crystal
require "awscr-ssm"

# Credentials resolved automatically from environment or instance metadata
client = Awscr::SSM::Client.new("ap-northeast-1")

# Fetch a plain parameter
value = client.get_parameter("/myapp/config/db_host")

# Fetch a SecureString parameter (decrypted)
secret = client.get_parameter("/myapp/secrets/api_key", with_decryption: true)

# Fetch all parameters under a path
result = client.get_parameters_by_path("/myapp/config/", with_decryption: true)
result[:parameters].each { |p| puts "#{p.name} = #{p.value}" }
```

## API

### `Client#get_parameter(key, with_decryption = false) : String`
Fetches a single parameter by name. Pass `with_decryption: true` for SecureString parameters.

### `Client#get_parameters_by_path(path, ...) : ParameterResult`
Fetches all parameters under a path prefix.

### `Client#put_parameter(key, value, secure = false, ...) : Int32`
Creates or updates a parameter. Returns the parameter version.

### `Client#delete_parameter(key) : Void`
Deletes a parameter.

### `Client#get_parameter_history(name, ...) : ParameterHistoryResult`
Fetches the version history of a parameter.
