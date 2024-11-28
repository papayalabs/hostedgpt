class AddGoogle < ActiveRecord::Migration[7.2]
  def up
    User.all.find_each do |user|
      user.api_services.create!(url: APIService::URL_GOOGLE, driver: :google, name: "Google Google")
    end
  end

  def down
    APIService.where(url: APIService::URL_GOOGLE, driver: :google).destroy_all
  end
end
