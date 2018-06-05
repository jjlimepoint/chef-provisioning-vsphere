# frozen_string_literal: true

require "bundler/gem_tasks"
require "chef/provisioning/vsphere_driver/version"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

RSpec::Core::RakeTask.new(:unit) do |task|
  task.pattern = "spec/unit_tests/*_spec.rb"
  task.rspec_opts = ["--color", "-f documentation"]
end

RSpec::Core::RakeTask.new(:integration) do |task|
  task.pattern = "spec/integration_tests/*_spec.rb"
  task.rspec_opts = ["--color", "-f documentation", "--out rspec.txt"]
end

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = ChefProvisioningVsphere::VERSION
    config.issues = true
  end
rescue LoadError
  puts "github_changelog_generator is not available. gem install github_changelog_generator to generate changelogs"
end

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"] # optional
  t.stats_options = ["--list-undoc"] # optional
end

task default: %i{style unit}

namespace :style do
  begin
    require "rubocop/rake_task"

    desc "Run Cookbook Ruby style checks"
    RuboCop::RakeTask.new(:cookstyle) do |t|
      t.requires = ["cookstyle"]
      t.patterns = ["lib/chef-dk/skeletons/code_generator"]
      t.options = ["--display-cop-names"]
    end
  rescue LoadError => e
    puts ">>> Gem load error: #{e}, omitting #{task.name}" unless ENV["CI"]
  end

  begin
    require "rubocop/rake_task"

    ignore_dirs = Regexp.union(%w{
      lib/chef-dk/skeletons/code_generator
      spec/unit/fixtures/chef-runner-cookbooks
      spec/unit/fixtures/cookbook_cache
      spec/unit/fixtures/example_cookbook
      spec/unit/fixtures/example_cookbook_metadata_json_only
      spec/unit/fixtures/example_cookbook_no_metadata
      spec/unit/fixtures/local_path_cookbooks
    })

    desc "Run Chef Ruby style checks"
    RuboCop::RakeTask.new(:chefstyle) do |t|
      t.requires = ["chefstyle"]
      t.patterns = `rubocop --list-target-files`.split("\n").reject { |f| f =~ ignore_dirs }
      t.options = ["--display-cop-names"]
    end
  rescue LoadError => e
    puts ">>> Gem load error: #{e}, omitting #{task.name}" unless ENV["CI"]
  end
end
