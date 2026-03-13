module Agent::User::Registerable
  extend ActiveSupport::Concern

  included do
    after_create :create_initial_assistants_etc
  end

  private

  def create_initial_assistants_etc
    Agent::Assistant.import_from_file(users: [self])
  end
end
