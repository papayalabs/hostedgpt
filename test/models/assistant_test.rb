require "test_helper"

class AssistantTest < ActiveSupport::TestCase
  test "initials" do
    samantha = assistants(:samantha)
    assert_equal "S", samantha.initials

    keith_gpt4 = assistants(:keith_gpt4)
    assert_equal "OG", keith_gpt4.initials

    keith_gpt3 = assistants(:keith_gpt3)
    assert_equal "G3", keith_gpt3.initials
  end

  test "to_s" do
    samantha = assistants(:samantha)
    assert_equal "Samantha", samantha.to_s
  end

  test "api_name can be updated directly" do
    assistant = assistants(:samantha)
    assistant.update!(api_name: "gpt-4o")
    assert_equal "gpt-4o", assistant.api_name
  end
end
