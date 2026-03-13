module Authenticate::LoginLogout

  def login_as(user)
    client = find_or_create_client_for(user)
    session_authenticate_with client
  end

  def logout_current
    Agent::Current.client.logout!
    reset_authentication
  end

  private

  def find_or_create_client_for(user)
    Agent::Current.client || user.clients.create!(
      platform: :web,
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
    )
  end

  def session_authenticate_with(client)
    if Agent::Current.initialize_with(client: client)
      session[:client_token] = client.token
      cookies.signed.permanent[:client_token] = { value: client.token, httponly: true, same_site: :lax }
    end
  end

  def reset_authentication
    session.delete(:client_token)
    cookies.delete(:client_token)
    Agent::Current.reset
  end

  def manual_login_allowed?
    true
  end
end
