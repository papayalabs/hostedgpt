module Agent
  class Assistant < ApplicationRecord
    include Agent::Assistant::Export
    include Agent::Assistant::Slug

    URL_OPEN_AI   = "https://api.openai.com/v1/"
    URL_ANTHROPIC = "https://api.anthropic.com/"
    URL_GROQ      = "https://api.groq.com/openai/v1/"
    URL_GEMINI    = "https://generativelanguage.googleapis.com/v1beta/"

    MAX_LIST_DISPLAY = 5

    belongs_to :user

    has_many :conversations, dependent: :destroy
    has_many :documents, dependent: :destroy
    has_many :runs, dependent: :destroy
    has_many :steps, dependent: :destroy
    has_many :messages, dependent: :destroy

    enum :driver, %w[openai anthropic gemini].index_by(&:to_sym)

    validates :tools, presence: true, allow_blank: true
    validates :name, :api_name, :driver, :url, :provider_name, presence: true

    normalizes :url, with: -> url { url.strip }
    encrypts :token

    scope :ordered, -> { order(:id) }
    scope :for_user, ->(user) { where(user_id: user.id).not_deleted }

    def ai_backend
      case driver
      when "openai"    then Agent::AIBackend::OpenAI
      when "anthropic" then Agent::AIBackend::Anthropic
      when "gemini"    then Agent::AIBackend::Gemini
      end
    end

    def requires_token?
      [URL_OPEN_AI, URL_ANTHROPIC, URL_GEMINI].include?(url)
    end

    def effective_token
      token.presence || default_llm_key
    end

    def supports_images?
      supports_images
    end

    def supports_pdf?
      supports_pdf
    end

    def supports_tools?
      supports_tools &&
        provider_name != "Groq" # TODO: Remove once Groq tool use is debugged
    end

    def supports_system_message?
      supports_system_message
    end

    def test_api_service(url = nil, token = nil)
      ai_backend.test_api_service(self, url, token)
    end

    def initials
      return nil if name.blank?

      parts = name.split(/[\- ]/)

      parts[0][0].capitalize +
        parts[1]&.try(:[], 0)&.capitalize.to_s
    end

    def to_s
      name
    end

    private

    def default_llm_key
      return nil unless Agent::Feature.default_llm_keys?
      return Agent::Setting.default_openai_key   if url == URL_OPEN_AI
      return Agent::Setting.default_anthropic_key if url == URL_ANTHROPIC
      return Agent::Setting.default_groq_key     if url == URL_GROQ
    end
  end
end
