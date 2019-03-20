
def configure_database
  remove_file 'config/database.yml'
  
  database_type = ask("Database da utilizzare ? ([m]ysql [p]ostgresql)")
  
  case database_type
  when 'p'
  configure_postgresql
  else
  configure_mysql
  end
end

def configure_postgresql
  copy_file 'config/postgresql/database.yml', 'config/database.yml'
  db_username =  ask_with_default("[Database Config][1/4] Nome Utente", 'postgres')
  db_name = ask_with_default("[Database Config][2/4] Nome database", application_name)
  db_port = ask_with_default("[Database Config][3/4] Porta del servizio", '32770')
  gsub_file('config/database.yml', /%username%/, db_username)
  gsub_file('config/database.yml', /%port%/, db_port)
  gsub_file('config/database.yml', /%application_name%/, db_name)
  enable_pg_uuid_extension if yes?("\n[Database Config][4/4] Utilizzare UUID ? y/n")
end

def configure_mysql
  copy_file 'config/mysql/database.yml', 'config/database.yml'
  db_username =  ask("\n[Database Config][1/4] Nome Utente ? (mysql)")
  db_username = 'postgres' unless db_username.present?
  db_name = ask("\n[Database Config][2/4] Nome database ? (#{application_name})")
  db_name = application_name unless db_name.present?
  db_port = ask("\n[Database Config][3/4] Porta del servizio ? (32784)")
  db_port = '32770' unless db_port.present?
  gsub_file('config/database.yml', /%username%/, db_username)
  gsub_file('config/database.yml', /%port%/, db_port)
  gsub_file('config/database.yml', /%application_name%/, db_name)
end

def enable_pg_uuid_extension
  generate "migration enable_pgcrypto_extension"
  file_name = Dir.entries("db/migrate").select{ |file| file.include?('enable_pgcrypto_extension')}.first
  insert_into_file "db/migrate/#{file_name}", "\n  enable_extension 'pgcrypto'", after: "def change"
  application 'config.generators { |generator| generator.orm :active_record, primary_key_type: :uuid }'
end


# run! 

configure_database
