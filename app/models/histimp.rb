class Histimp < ActiveRecord::Base
  include Assistit

  belongs_to :historial

  validates :historial_id,
    :presence => true, :on => :save
  validates :hislin,
    :presence => true
  validates :ctkey,
    :presence => true
  validates :impbas,
    :presence => true
  validates :impbas, :numericality => true, :if => :impbas

  def validationTitle
    'Impost'
  end

end
