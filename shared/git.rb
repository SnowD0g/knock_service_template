# locale
  puts "\n[Git] Inizializzo git locale"
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
  puts "[Git] Inizializzo git locale: OK"

  #clone bare
  puts "\n[Git] Clonazione bare in locale"
  tempdir = Dir.mktmpdir("service")
  #at_exit { FileUtils.remove_entry(tempdir) }
  repo_name = "#{application_name}.git"
  git clone: "--bare . #{tempdir}/#{repo_name}"
  puts "\n[Git] Clonazione bare in locale: OK"
  
  #remote
  puts "\n[Git] Remote Repository"
  server = ask("\nGit][1/4] Server Remoto (web@ns3051471.ovh.net:) ?")
  server = "web@ns3051471.ovh.net:" unless server.present?
  
  remote_path = ask("\nGit][2/4] Path git (/home/web/git/) ?")
  remote_path = "/home/web/git/" unless remote_path.present?
  remote_url = "#{server}#{remote_path}"

  puts "\n[Git][3/4] Creo il remote:"
  git remote: "add deploy #{remote_url}#{repo_name}" 
  #copia bare
  puts "\n[Git][4/4] Copio il clone bare sul server remoto"
  run "scp -r #{tempdir}/#{repo_name} #{server}/tmp"
  puts "Copia effettuata con successo! Spostare manualmente il bare da #{server}/tmp -> #{remote_url}#{repo_name}"
