class Empresa < ActiveRecord::Base
has_many :habilitacios
  has_many :users, :through => :habilitacios

  validates :empnom,
    :presence => true

 # validates :expiracio_contracte,
 #   :presence => true,
 #   :on => :create

 # validate :expiracio_contracte_is_a_date?,
  #  :if => :expiracio_contracte

  validate :activada_is_a_bool?,
    :if => :activada

  private

    def expiracio_contracte_is_a_date?
      errors.add(:ctdcta, :not_a_date) unless expiracio_contracte.is_a_date?
    end

    def activada_is_a_bool?
     if !(activada.is_a?(TrueClass) || activada.is_a?(FalseClass))
       errors.add(:activada, 'No es un valor true/false') 
     end
    end

  public

    def create_schema
      random_name = (0...10).map{65.+(rand(26)).chr}.join.downcase
      
      begin 
        Apartment::Database.create(random_name)
        update_attributes(:schema => random_name)
      rescue Exception => e
        logger.error e
      end

      return random_name
    end

    def self.seed_schema(schema)
      begin 
        Apartment::Database.process(schema) do
          Apartment::Database.seed
        end
      rescue Exception => e
        logger.error e
      end
    end

end
