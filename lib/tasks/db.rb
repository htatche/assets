task :cleandb  => [:environment] do
  Historial.all.each { |i| i.destroy }
  Histgen.all.each { |i| i.destroy }
  Histimp.all.each { |i| i.destroy }
  Histpag.all.each { |i| i.destroy }
  Moviment.all.each { |i| i.destroy }
end

task :cleanusers  => [:environment] do
  User.all.each { |i| i.destroy }
end
