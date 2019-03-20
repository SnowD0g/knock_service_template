class DemocomApplication
  attr_reader :application_name, :ruby_version, :server_url, :repo_path

  def initialize(application_name, ruby_version, server_url, repo_path)
    @application_name = application_name.underscore
    @ruby_version = ruby_version
    @server_url = server_url
    @repo_path = repo_path
  end

  def repo_name
    "#{application_name}.git"
  end

  def remote_repo
    "#{server_url}:#{repo_path}#{application_name}.git"
  end
end
