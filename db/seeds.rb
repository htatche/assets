require 'active_record/fixtures'

tenant_dir = "#{Rails.root}/test/fixtures/tenant"

Dir["#{tenant_dir}/*"].map { |file| 
  filename = File.basename(file, File.extname(file))
  puts "Seeding #{tenant_dir}/#{file}"
  ActiveRecord::Fixtures.create_fixtures(tenant_dir, filename)
}
