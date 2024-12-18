require "test_helper"

class Authenticate::ByHttpHeaderTest < ActionDispatch::IntegrationTest
  test "should login user via header" do
    stub_features(http_header_authentication: true) do
      get root_url, headers: existing_http_auth_user
      assert_login_completed_for users(:rob)
    end
  end

  test "should create and login new user" do
    stub_features(http_header_authentication: true, registration: true) do
      assert_difference "User.count", 1 do
        assert_difference "Person.count", 1 do
          get root_url, headers: new_http_auth_user
        end
      end
    end
    user = User.last

    assert user.present?
    assert_equal new_http_auth_user[Setting.http_header_auth_email], user.email
    assert_equal new_http_auth_user[Setting.http_header_auth_name], user.name
    assert user.http_header_credential
    assert user.http_header_credential.authentications.present?
    assert_equal 1, user.http_header_credential.authentications.count
    assert_login_completed_for user
  end

  test "should create and login new user when NAME IS OMITTED" do
    stub_features(http_header_authentication: true, registration: true) do
      assert_difference "User.count", 1 do
        assert_difference "Person.count", 1 do
          get root_url, headers: new_http_auth_user.except(Setting.http_header_auth_name)
        end
      end
    end
    user = User.last

    assert user.present?
    assert_equal new_http_auth_user[Setting.http_header_auth_email], user.email
    assert_equal "john doe", user.name  # generated by fallback_name
    assert user.http_header_credential
    assert user.http_header_credential.authentications.present?
    assert_equal 1, user.http_header_credential.authentications.count
    assert_login_completed_for user
  end

  test "fallback_name_from helper works even if there are multiple periods in email address" do
    assert_equal "first last", ApplicationController.new.send(:fallback_name_from, "first.random.more.last@example.com")
  end

  test "should render unauthorized if no HTTP header present and no other auth is allowed" do
    stub_features(
      http_header_authentication: true,
      password_authentication: false,
      google_authentication: false,
      microsoft_graph_authentication: false
    ) do
      get root_url
    end
    assert_response :unauthorized
    assert_equal response.body, "Unauthorized"
  end

  test "should render UN-AUTHORIZED if REGISTRATION DISABLED and NO HEADERS are provided and MANUAL AUTH IS DISABLED" do
    stub_features(
      http_header_authentication: true,  # note: this disables manual auth (e.g. password, google)
    ) do
      get root_url
    end
    assert_response :unauthorized
    assert_equal response.body, "Unauthorized"
  end

  test "should render UN-AUTHORIZED if REGISTRATION DISABLED and NEW uid" do
    headers = new_http_auth_user
    refute HttpHeaderCredential.find_by(auth_uid: headers[Setting.http_header_auth_uid])

    stub_features(
      http_header_authentication: true, # note: this disables manual auth (e.g. password, google)
      registration: false
    ) do
      get root_url, headers: headers
    end
    assert_response :unauthorized
    assert_equal response.body, "Unauthorized"
  end

  test "should render AUTHORIZED if REGISTRATION DISABLED and EXISTING uid" do
    headers = existing_http_auth_user
    assert HttpHeaderCredential.find_by(auth_uid: headers[Setting.http_header_auth_uid])

    stub_features(
      http_header_authentication: true,
      registration: false
    ) do
      get root_url, headers: headers
    end
    assert_login_completed_for users(:rob)
  end

  private

  def assert_login_completed_for(user)
    assert_response :redirect
    assert_redirected_to new_assistant_message_path(user.assistants.ordered.first)
    follow_redirect!
    assert_response :success
    assert_logged_in(user)
  end

  def existing_http_auth_user
    { Setting.http_header_auth_uid => credentials(:rob_http_header).auth_uid }
  end

  def new_http_auth_user
    {
      Setting.http_header_auth_uid => "new_uid",
      Setting.http_header_auth_email => "john.doe@hostedgpt.com",
      Setting.http_header_auth_name => "John Doe"
    }
  end
end
