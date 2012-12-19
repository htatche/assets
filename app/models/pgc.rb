class Pgc < ActiveRecord::Base
  set_primary_key :id
  has_many :comptes

  has_ancestry :orphan_strategy => :destroy

  before_validation :formatPgccte, :on => :create
  before_validation { |pgc| pgc.pgccla = Empresa.first.emppgc }

  validates :pgccte,
    :presence => true,
    :numericality => { :only_integer => true },
    :uniqueness => { :scope => :pgccla }, :on => :create

  validates :pgcdes,
    :presence => true

  # Verify that only one char is sent as pgccte from form, and
  # format pgccte if we are creating a subgrup
  def formatPgccte
    if pgccte.nil? 
      errors.add(:pgccte, 'no pot estar buit')
    else
      if parent_id.nil?
        if pgccte.to_s.length > 1
          errors.add(:pgccte, "maxim un caracter")  
        end
      else
        @parent = Pgc.where(:id => parent_id).first.pgccte

        if pgccte.to_s.length > @parent.to_s.length + 1
          errors.add(:pgccte, "maxim un caracter")  
        else
          self.pgccte = @parent * 10 + pgccte
        end
      end
    end
  end

  ## Codi no utilitzat
  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
          {:name => node.pgcdes, :id => node.id, :children => json_tree(sub_nodes).compact}
    end
  end
  ##

end
