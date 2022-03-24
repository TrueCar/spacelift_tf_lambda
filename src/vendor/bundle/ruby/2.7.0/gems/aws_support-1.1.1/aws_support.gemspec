# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_support/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws_support'
  spec.version       = AwsSupport::VERSION
  spec.authors       = ['Eric Lee']
  spec.email         = ['elee@truecar.com']

  spec.summary       = 'AWS support libraries'
  spec.description   = 'Utilities and conventions for using AWS services'
  spec.homepage      = 'https://git.corp.tc/infra/truecar_aws_support_ruby'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://artifactory.corp.tc"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }  # TODO??
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-core'
  spec.add_dependency 'aws-sdk-secretsmanager'
  spec.add_dependency 'aws-partitions', '~> 1', '>= 1.228.0'  # necessary for STS regional

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'irb'
end
