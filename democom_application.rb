class DemocomApplication
  attr_reader :application_name, :ruby_version

  def initialize
    @application_name = ask('Nome Applicazione:').underscore
    @ruby_version = ask('Versione ruby:').underscore
  end
  
  def ask(string)
    log '', string
    STDIN.gets.strip
  end
end
