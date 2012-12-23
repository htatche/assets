Apartment.configure do |config|
  config.excluded_models = ["User", "Empresa"]
  config.database_names = lambda{ Empresa.select(:database_name).map { |i| i.database_name } }
end
