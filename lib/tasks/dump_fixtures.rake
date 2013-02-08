namespace :db do
  namespace :fixtures do    
    desc 'Create YAML test fixtures from data in an existing database.  
    Defaults to development database.  Specify RAILS_ENV=production on command line to override.'
    task :dump => :environment do
      sql  = "SELECT * FROM %s"
      fixtures_dir = "#{Rails.root}/test/fixtures/tenant/"
      skip_tables = ["schema_info",
                     "schema_migrations",
                     "sessions",
                     "users",
                     "users_empreses",
                     "empresas"]

      FileUtils.mkdir_p(fixtures_dir)
      ActiveRecord::Base.establish_connection(Rails.env)

      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
        i = "000"
        File.open("#{fixtures_dir}#{table_name}.yml", "w") do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hash, record|
            hash["#{table_name}_#{i.succ!}"] = record
            hash
          }.to_yaml
        end
      end
    end
  end
end
