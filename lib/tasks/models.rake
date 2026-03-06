Rake::Task["db:prepare"].enhance do
  Rake::Task["assistants:import"].invoke
end
