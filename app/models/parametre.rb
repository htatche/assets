class Parametre < ActiveRecord::Base

  validates :pgc_id,
    :presence => true,
    :length => { :in => 1..2 },
    :numericality => { :only_integer => true }

  validate :pgc_exists?

  validates :long_compte,
    :presence => true,
    :length => { :in => 1..2 },
    :numericality => { :only_integer => true }

  validates :long_sufix,
    :presence => true,
    :length => { :in => 1..2 },
    :numericality => { :only_integer => true }

  private

    def pgc_exists?
      begin
        Pgctipus.exists?(pgc_id)
      rescue ActiveRecord::RecordNotFound => e
        errors.add(:pgc, 'No existeix')
      end
    end
    
  public

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
