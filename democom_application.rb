class DemocomApplication
  attr_reader :name, :ruby_version
  alias_method :name, :application_name
  
  def initialize
    @name = ask('Nome Applicazione:').underscore
    @ruby_version = ask('Versione ruby:').underscore
  end
end
