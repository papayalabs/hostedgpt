module Agent
  class SDK::Patch < SDK::Verb
    def param(params = {})
      hash = OpenData.new(params).to_h

      response = patch(@url) do |req|
        req.headers = @headers
        req.body = hash.to_json
      end

      handle(response)
    end
  end
end
