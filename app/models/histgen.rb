class Histgen < ActiveRecord::Base
  include Assistit

  belongs_to :historial

  validates :historial_id,
    :presence => true
  validates :hislin,
    :presence => true
  validates :ctkey,
    :presence => true
  validates :import,
    :presence => true
  validates :import, :numericality => true, :if => :import

  def self.validationTitle
    'Apunt'
  end
end
