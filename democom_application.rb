class DemocomApplication
  attr_reader :application_name, :ruby_version

  def initialize
    @application_name = ask('Nome Applicazione:').underscore
    @ruby_version = ask('Versione ruby:')
  end
  
  def remote_repo
    "web@ns123123:/va/git/#{application_name}.git"
  end
  
  def ask(string)
    puts string
    STDIN.gets.strip
  end
end
