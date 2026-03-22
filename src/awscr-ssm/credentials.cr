module Awscr
  module SSM
    module Credentials
      def self.default_provider : Aws::Credentials::Provider
        Aws::Credentials::Providers.new([
          Aws::Credentials::EnvProvider.new,
          Aws::Credentials::SharedCredentialFileProvider.new,
        ] of Aws::Credentials::Provider)
      end
    end
  end
end
