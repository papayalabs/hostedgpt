module Agent
  class Current < ActiveSupport::CurrentAttributes
    attribute :user
    attribute :client

    attribute :message # Maybe this should not be here, but get_next_ai_message_job calls tools and tools need this context

    def self.initialize_with(client: nil)
      self.client = client
      self.user = client.user if client&.authenticated?
      self.user
    end

    def self.reset
      self.user = self.client = nil
    end
  end
end
