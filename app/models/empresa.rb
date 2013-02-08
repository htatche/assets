class Empresa < ActiveRecord::Base
has_many :habilitacios
  has_many :users, :through => :habilitacios

  validates :empnom,
    :presence => true

  #validates :expiracio_contracte,
  #  :presence => true,
  #  :on => :create

  #validate :expiracio_contracte_is_a_date?,
  #  :if => :expiracio_contracte
  validate :activada_is_a_bool?,
    :if => :activada

  private

    def expiracio_contracte_is_a_date?
      begin
        DateTime.parse(expiracio_contracte) 
      rescue
        errors.add(:expiracio_contracte, 'No es una data')
      end
    end


    def activada_is_a_bool?
     if !(activada.is_a?(TrueClass) || activada.is_a?(FalseClass))
       errors.add(:activada, 'No es un valor true/false') 
     end
    end

  public
    
    def self.cteMaxLength(empkey)
      find(empkey).emploc
    end

    def create_schema
      random_name = (0...10).map{65.+(rand(26)).chr}.join.downcase
      
      begin 
        Apartment::Database.create(random_name)
        Apartment::Database.process(random_name) do
          Apartment::Database.seed
        end

        update_attributes(:schema => random_name)
        return random_name
        
      rescue Exception => e
        logger.debug e.inspect
        exit
      end
    end

end
