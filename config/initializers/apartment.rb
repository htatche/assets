Apartment.configure do |config|
  config.excluded_models = ["User", "Empresa", "Habilitacio"]
  config.database_names = lambda{ Empresa.select(:database_name).map { |i| i.schema } }
end
