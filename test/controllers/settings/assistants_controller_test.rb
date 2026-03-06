require "test_helper"

class Settings::AssistantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @assistant = assistants(:samantha)
    @user = @assistant.user
    login_as @user
  end

  test "should get new" do
    get new_settings_assistant_url
    assert_response :success
  end

  test "should create assistant" do
    params = assistants(:samantha).slice(:name, :description, :instructions, :provider_name, :driver, :url, :api_name)

    assert_difference("Assistant.count") do
      post settings_assistants_url, params: { assistant: params }
    end

    assert_redirected_to edit_settings_assistant_url(Assistant.last)
    assert_nil flash[:error]
    assert_equal params, Assistant.last.slice(:name, :description, :instructions, :provider_name, :driver, :url, :api_name)
  end

  test "should show error when creating assistant with duplicate slug" do
    existing_assistant = assistants(:samantha)
    params = {
      name: "New Assistant",
      slug: existing_assistant.slug,
      description: "A new description",
      instructions: "New instructions",
      provider_name: "OpenAI",
      driver: "openai",
      url: Assistant::URL_OPEN_AI,
      api_name: "gpt-4o"
    }

    assert_no_difference("Assistant.count") do
      post settings_assistants_url, params: { assistant: params }
    end

    assert_response :unprocessable_content
    assert_contains_text "main", "Slug has already been taken"
  end

  test "should get edit" do
    get edit_settings_assistant_url(@assistant)
    assert_response :success
    assert_contains_text "div#nav-container", "Your Account"
    assert_contains_text "div#nav-container", "New Assistant"
  end

  test "form should display a DELETE button if this is not your last assistant" do
    assert @user.assistants.length > 1, "User needs to have more than one assistant"
    get edit_settings_assistant_url(@assistant)
    assert_response :success
    assert_contains_text "main", "Delete"
  end

  test "form should NOT display a DELETE button if this is your last assistant" do
    @user.assistants.where.not(id: @assistant.id).map(&:destroy!)
    @user.reload
    assert @user.assistants.length == 1, "Test user needs to have more than one assistant"
    get edit_settings_assistant_url(@user.assistants.first)
    assert_response :success
    assert_contains_text "main", "Delete"
  end

  test "should allow provider/model field editing" do
    get edit_settings_assistant_url(@assistant)
    assert_select "label", "Provider name"
    assert_select "input#assistant_api_name"
  end

  test "should update api_name" do
    params = { api_name: "gpt-4o-mini" }
    patch settings_assistant_url(@assistant), params: { assistant: params }
    assert_equal "gpt-4o-mini", @assistant.reload.api_name
  end

  test "should update assistant" do
    params = assistants(:samantha).slice(:name, :description, :instructions).transform_values { |value| "#{value}-2" }
    patch settings_assistant_url(@assistant), params: { assistant: params }

    assert_redirected_to edit_settings_assistant_url(@assistant)
    assert_nil flash[:error]
    assert_equal params, @assistant.reload.slice(:name, :description, :instructions)
  end

  test "destroy should soft-delete assistant" do
    assert_difference "Assistant.count", 0 do
      delete settings_assistant_url(@assistant)
    end

    assert @assistant.reload.deleted?
    assert_redirected_to new_settings_assistant_url
    assert flash[:notice].present?, "There should have been a success message"
    refute flash[:alert].present?, "There should NOT have been an error message"
  end

  test "destroy on the last assistant should not delete it" do
    user = @assistant.user
    user.assistants.where.not(id: @assistant.id).map(&:destroy)

    assert_no_difference "Assistant.count" do
      delete settings_assistant_url(@assistant)
    end

    refute @assistant.reload.deleted?
    assert_redirected_to new_settings_assistant_url
    refute flash[:notice].present?, "There should NOT have been a success message"
    assert flash[:alert].present?, "There should have been an error message"
  end
end
