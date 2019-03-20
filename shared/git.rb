def init_git
  # locale
  puts "\n[Git] Inizializzo git locale"
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
  git branch: 'staging'
  puts "[Git] Inizializzo git locale: OK"

  #clone bare
  puts "\n[Git][1/3] Clonazione bare in locale"
  tempdir = Dir.mktmpdir("service")
  at_exit { FileUtils.remove_entry(tempdir) }
  git clone: "--bare . #{tempdir}/#{repo_name}"
  puts "\n[Git][1/3] Clonazione bare in locale: OK"
  
  #remote
  puts "\n[Git][2/3] Remote Repository"
  git remote: "add deploy #{remote_url}#{repo_name}" 
  puts "\n[Git][2/3] Remote Repository: OK"
  
  #copia bare
  puts "\n[Git][3/3] Copia Remota del Bare"
  run "scp -r #{tempdir}/#{repo_name} #{server}/tmp"
  puts "\n[Git][3/3] Copia Remota del Bare: OK"
  puts "Copia effettuata con successo! Spostare manualmente il bare da #{server}/tmp -> #{remote_url}#{repo_name}"
end

init_git
