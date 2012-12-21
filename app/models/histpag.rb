class Histpag < ActiveRecord::Base
  include Assistit

  belongs_to :historial

  validates :historial_id,
    :presence => true,
    :on => :save
  validates :hislin,
    :presence => true
  validates :fpkey,
    :presence => true
  validates :datven,
    :presence => true
  validates :import,
    :presence => true
  validates :datven,
    :presence => true
  validate :datven_is_date, :if => :datven

  def datven_is_date
    if !datven.is_a?(Date)
      errors.add(:datven, 'no es una data correcta') 
    end
  end

  def validationTitle
    'Pagament'
  end

end
