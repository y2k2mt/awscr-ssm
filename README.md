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

Credentials are resolved automatically using the standard AWS credential chain:

1. Environment variables (`AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY`)
2. EC2 instance metadata (IMDSv2)

`AWS_SESSION_TOKEN` is supported for temporary credentials (IAM roles, SSO, etc).

You can also provide credentials explicitly:

```crystal
require "awscr-ssm"

creds = Awscr::SSM::SimpleCredentials.new("AK...", "SECRET...")
client = Awscr::SSM::Client.new("us-east-1", creds)
```

## Quick Start

```crystal
require "awscr-ssm"

# Credentials resolved automatically from environment or instance metadata
client = Awscr::SSM::Client.new("us-east-1")

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
