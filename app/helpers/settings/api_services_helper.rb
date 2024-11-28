module Settings
  module APIServicesHelper
    def official?(model)
      openai?(model) || anthropic?(model) || groq?(model) || google?(model)
    end

    def openai?(api_service)
      api_service.url == APIService::URL_OPEN_AI
    end

    def anthropic?(api_service)
      api_service.url == APIService::URL_ANTHROPIC
    end

    def groq?(api_service)
      api_service.url == APIService::URL_GROQ
    end

    def google?(api_service)
      api_service.url == APIService::URL_GOOGLE
    end
  end
end
