class Brain < ActiveRecord::Base
  
  def self.getDeureHaver(brakey)
    w = ['D', 'H', 'H', 'H', 'D']

    brain = find_by_brakey(brakey)

    if brain.present?
      if brain.brapor = 1 
        w[0] = 'D'
        w[1] = 'H'
      else
        w[0] = 'H'
        w[1] = 'D'
      end

      if brain.braipr = 1 
        w[2] = 'D'
        w[2] = 'H'
      end

      if brain.braipa = 1 
        w[3] = 'D'
        w[3] = 'H'
      end

      return w
    else
      raise 'Error amb el brain'
    end
    
  end

  def self.grupOri(opckey)
    @brakey = Menudet.find(opckey).brakey

    @grup = find_by_brakey(@brakey)
    @grup.braori.nil? ? '' : @grup.braori
  end

  def self.grupDest(opckey)
    @brakey = Menudet.find(opckey).brakey

    @grup = find_by_brakey(@brakey)
    @grup.bradest.nil? ? '' : @grup.bradest
  end
end
