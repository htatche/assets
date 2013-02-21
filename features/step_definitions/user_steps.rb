#Given /^Visitem la pagina de login$/
When /^'(.*)' inicie sessio$/ do |email|
  visit(login_path)
  fill_in( "username_or_email", :with => email )
  fill_in( "login_password", :with => "icetea069" )
  click_button( "Entrar" )
end

Then /^Tindria que veure la home de la empresa$/ do
  page.has_selector?('div.empresa-home')
end
