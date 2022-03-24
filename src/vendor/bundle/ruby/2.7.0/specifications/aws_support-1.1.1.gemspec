# -*- encoding: utf-8 -*-
# stub: aws_support 1.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "aws_support".freeze
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://artifactory.corp.tc" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eric Lee".freeze]
  s.date = "2021-11-19"
  s.description = "Utilities and conventions for using AWS services".freeze
  s.email = ["elee@truecar.com".freeze]
  s.homepage = "https://git.corp.tc/infra/truecar_aws_support_ruby".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "AWS support libraries".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<aws-sdk-core>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<aws-sdk-secretsmanager>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<aws-partitions>.freeze, ["~> 1", ">= 1.228.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.17"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<dotenv>.freeze, ["~> 2.7"])
    s.add_development_dependency(%q<irb>.freeze, [">= 0"])
  else
    s.add_dependency(%q<aws-sdk-core>.freeze, [">= 0"])
    s.add_dependency(%q<aws-sdk-secretsmanager>.freeze, [">= 0"])
    s.add_dependency(%q<aws-partitions>.freeze, ["~> 1", ">= 1.228.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.17"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<dotenv>.freeze, ["~> 2.7"])
    s.add_dependency(%q<irb>.freeze, [">= 0"])
  end
end
