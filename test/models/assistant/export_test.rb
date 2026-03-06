require "test_helper"

class Assistant::ExportTest < ActiveSupport::TestCase
  test "export_to_file json includes expected keys" do
    path = Rails.root.join("tmp/assistants.json")
    Assistant.export_to_file(path:, assistants: users(:keith).assistants.not_deleted)
    assert File.exist?(path)
    storage = JSON.load_file(path)
    list = storage["assistants"]
    expected_keys = %w[name description instructions slug provider_name driver url api_name supports_images supports_tools supports_system_message supports_pdf]
    assert_equal expected_keys.sort, (list.first.keys & expected_keys).sort
  end

  test "export_to_file yaml includes expected keys" do
    path = Rails.root.join("tmp/assistants.yml")
    Assistant.export_to_file(path:, assistants: users(:keith).assistants.not_deleted)
    assert File.exist?(path)
    storage = YAML.load_file(path)
    list = storage["assistants"]
    expected_keys = %w[name description instructions slug provider_name driver url api_name supports_images supports_tools supports_system_message supports_pdf]
    assert_equal expected_keys.sort, (list.first.keys & expected_keys).sort
  end

  test "import_from_file updates existing undeleted assistant" do
    user = users(:keith)
    existing = user.assistants.not_deleted.first
    new_name = "Updated Name"
    data = [{ name: new_name, slug: existing.slug, description: "d", instructions: "i",
              provider_name: existing.provider_name, driver: existing.driver, url: existing.url,
              api_name: existing.api_name, supports_images: false, supports_tools: false,
              supports_system_message: false, supports_pdf: false }]
    path = Rails.root.join("tmp/update_existing.yml")
    File.write(path, { "assistants" => data }.to_yaml)
    assert_no_difference("Assistant.count") { Assistant.import_from_file(path:, users: [user]) }
    assert_equal new_name, existing.reload.name
  end

  test "import_from_file skips deleted assistant" do
    user = users(:keith)
    deleted = user.assistants.first
    original_name = deleted.name
    deleted.deleted!
    data = [{ name: "New", slug: deleted.slug, description: "d", instructions: "i",
              provider_name: "OpenAI", driver: "openai", url: Assistant::URL_OPEN_AI,
              api_name: "gpt-4o", supports_images: true, supports_tools: true,
              supports_system_message: true, supports_pdf: false }]
    path = Rails.root.join("tmp/skip_deleted.yml")
    File.write(path, { "assistants" => data }.to_yaml)
    assert_no_difference("Assistant.count") { Assistant.import_from_file(path:, users: [user]) }
    assert_equal original_name, deleted.reload.name
  end

  test "import_from_file creates new assistant" do
    user = users(:keith)
    data = [{ name: "Brand New", slug: "brand-new-slug", description: "d", instructions: "i",
              provider_name: "OpenAI", driver: "openai", url: Assistant::URL_OPEN_AI,
              api_name: "gpt-4o", supports_images: true, supports_tools: true,
              supports_system_message: true, supports_pdf: false }]
    path = Rails.root.join("tmp/new_assistant.yml")
    File.write(path, { "assistants" => data }.to_yaml)
    assert_difference("Assistant.count", 1) { Assistant.import_from_file(path:, users: [user]) }
    assert_not_nil user.assistants.find_by(slug: "brand-new-slug")
  end

  test "import_from_file with only new assistants" do
    user = users(:keith)
    user.assistants.destroy_all
    data = [{ name: "new assistant", external_id: "new external_id", description: "d", instructions: "i",
              provider_name: "OpenAI", driver: "openai", url: Assistant::URL_OPEN_AI,
              api_name: "gpt-4o", supports_images: true, supports_tools: true,
              supports_system_message: true, supports_pdf: false }]
    path = Rails.root.join("tmp/newmodels.yml")
    File.write(path, { "assistants" => data }.to_yaml)
    assert_difference("Assistant.count", 1) { Assistant.import_from_file(path:, users: [user]) }
    assert user.assistants.find_by(external_id: "new external_id")
  end

  test "import_from_file json with only new assistants" do
    user = users(:keith)
    user.assistants.destroy_all
    data = [{ name: "new assistant", slug: "new-assistant", description: "d", instructions: "i",
              provider_name: "OpenAI", driver: "openai", url: Assistant::URL_OPEN_AI,
              api_name: "gpt-4o", supports_images: true, supports_tools: true,
              supports_system_message: true, supports_pdf: false }]
    path = Rails.root.join("tmp/newmodels.json")
    File.write(path, { "assistants" => data }.to_json)
    assert_difference("Assistant.count", 1) { Assistant.import_from_file(path:, users: [user]) }
    assert user.assistants.find_by(name: "new assistant")
  end

  test "import_from_file with existing assistants by slug" do
    user = users(:keith)
    assistant = user.assistants.not_deleted.first
    data = [{ name: "new name", slug: assistant.slug, description: "new desc", instructions: "new inst",
              provider_name: assistant.provider_name, driver: assistant.driver, url: assistant.url,
              api_name: "gpt-4o", supports_images: true, supports_tools: true,
              supports_system_message: true, supports_pdf: false }]
    path = Rails.root.join("tmp/newmodels.yml")
    File.write(path, { "assistants" => data }.to_yaml)
    assert_no_difference("Assistant.count") { Assistant.import_from_file(path:, users: [user]) }
    assistant.reload
    assert_equal "new name", assistant.name
    assert_equal "new desc", assistant.description
    assert_equal "gpt-4o", assistant.api_name
  end
end
