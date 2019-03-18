module Permission
  extend ActiveSupport::Concern
  # check_permission_for(user_type, actions)
  #
  # Class method che, se incluso in un Controller, permette la definizione dinamica di un before_action che controlla
  # i permessi di un determinato tipo di utente (user_type) su una lista di azioni del controller (actions).
  #
  # Il metodo utilizzato dal before_action non deve essere implementato, è l'override del method_missing
  # che, dinamicamente, invoca sul model User un metodo user_type? per verificarne il tipo.
  #
  # Il parametro actions è opzionale e se non specificato si riferisce alle azioni [:index, :show, :create, :update, :destroy]
  # Es.
  # check_permission_for :admin, [:create, :destroy]
  #
  # -> before_action generato
  # before_action check_permission_for_admin, only: [:create, :destroy]
  #
  # -> metodo utilizzato nel Model
  # class User
  #   def admin?
  #     .. controllo sul tipo
  #   end
  # end
  #
  included do
    def self.check_permission_for(user_type, actions = [:index, :show, :create, :update, :destroy])
      self.before_action "check_permission_#{user_type}".to_sym, only: actions
    end

    def method_missing(method_name, *args, &block)
      return super unless method_name.to_s.include?('check_permission_')
      user_type = method_name.to_s.split('check_permission_').last
      head(:unauthorized) unless current_user.try("#{user_type}?")
    end
  end
end
