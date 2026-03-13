namespace :assistants do
  desc "Export assistants to a file, defaulting to assistants.yml"
  task :export, [:path] => :environment do |t, args|
    args.with_defaults(path: Rails.root.join(Agent::Assistant::Export::DEFAULT_ASSISTANT_FILE))
    warn "Exporting assistants to #{args[:path]}"
    unless Agent::User.first
      warn "No users found, unable to export assistants"
      exit 1
    end
    assistants = Agent::User.first.assistants.ordered.not_deleted
    Agent::Assistant.export_to_file(path: args[:path], assistants:)
  end

  desc "Import assistants to all users from a file, defaulting to assistants.yml"
  task :import, [:path] => :environment do |t, args|
    args.with_defaults(path: Rails.root.join(Agent::Assistant::Export::DEFAULT_ASSISTANT_FILE))
    warn "Importing assistants from #{args[:path]}"
    users = Agent::User.all
    Agent::Assistant.import_from_file(path: args[:path], users:)
  end
end
