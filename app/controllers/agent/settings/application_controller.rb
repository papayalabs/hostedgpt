module Agent
  module Settings
    class ApplicationController < Agent::ApplicationController
      before_action :set_settings_menu

      layout "settings"

      private

      def set_settings_menu
        # controller_name => array of items
        @settings_menu = {
          users: {
            I18n.t("app.settings.people.menu.account") => edit_settings_user_path,
          },

          memories: {
            I18n.t("app.settings.memories.menu.title") => settings_memories_path,
          },

          assistants: Agent::Current.user.assistants.ordered.map {
            |assistant| [ assistant, edit_settings_assistant_path(assistant) ]
          }.to_h.merge({
            I18n.t("app.settings.assistants.menu.new") => new_settings_assistant_path
          }),
        }
      end
    end
  end
end
