class ApplicationController < ActionController::Base
  include Authenticate

  skip_before_action :verify_authenticity_token, if: :api_request?
  before_action :set_locale
  before_action :set_system_ivars

  def default_render(*args)
    if api_request?
      json_payload = user_defined_ivars.map { |i| [ i.to_s[1..], instance_variable_get(i) ] }.to_h
      render json: json_payload, status: :ok
    else
      super(*args)
    end
  end

  def redirect_to(*args)
    if api_request?
      options = args.extract_options!
      status = options[:status]

      if status == :see_other
        render json: options.merge(redirect_to: args.first), status: :ok
        return
      end
    else
      super(*args)
    end
  end

  private

  def set_locale
    I18n.locale = extract_locale_param || I18n.default_locale
  end

  def extract_locale_param
    l = params[:locale]&.to_sym
    return l if l && I18n.available_locales.include?(l)
    nil
  end

  def default_url_options
    { locale: (I18n.locale unless I18n.locale == I18n.default_locale) }.compact
  end

  def set_system_ivars
    @system_ivars = public_ivars
  end

  def public_ivars
    instance_variables.select { |i| !i.to_s.starts_with?("@_") }
  end

  def api_request?
    request.format.json?
  end

  def user_defined_ivars
    public_ivars - @system_ivars - ["system_ivar"]
  end

  def ensure_manual_login_allowed
    return if manual_login_allowed?
    head :not_found
  end
end
