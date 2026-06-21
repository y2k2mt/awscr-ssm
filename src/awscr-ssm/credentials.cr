module Awscr
  module SSM
    module Credentials
      def self.default_provider : Aws::Credentials::Provider
        Aws::Credentials::Providers.new([
          Aws::Credentials::EnvProvider.new,
          Aws::Credentials::SharedCredentialFileProvider.new,
          Aws::Credentials::InstanceMetadataProvider.new,
          Aws::Credentials::ContainerCredentialProvider.new,
        ] of Aws::Credentials::Provider)
      end
    end
  end
end
