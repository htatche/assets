class Parametre < ActiveRecord::Base


  # Nomes hi haura un registre en aquesta taula
  def self.long_compte
    first.long_compte
  end
  
  def self.long_sufix
    first.long_sufix
  end

  def self.pgc_id
    first.pgc_id
  end
end
