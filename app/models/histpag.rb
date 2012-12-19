class Histpag < ActiveRecord::Base
  include Assistit

  belongs_to :historial

  validates :historial_id,
    :presence => true
  validates :hislin,
    :presence => true
  validates :fpkey,
    :presence => true
  validates :datven,
    :presence => true
  validates :import,
    :presence => true

  def validationTitle
    'Pagament'
  end

end
