unless User.all.any?
  User.create(email: 'prova@test.it', password: 'password')
end
