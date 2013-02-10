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

  def construir_filtre_apunts(emplos, compte, signe)
    var = compte[0, compte.length - emplos]

    fields = [
      ['braori', 'brapor'],
      ['brades', 'brapde'],
      ['braimp','braipr'],
      ['brapag', 'braipa'],
      ['brareb', 'braire']
    ]

    fields.each { |f|
      #ssql = "#{f[1]} = #{signe} AND #{f[0]} = "
      #       "Mid(#{var}, 1, Length(Concat(#{f[0]}, '0')) - 1)) OR"

      ssql = ssql + "(#{f[1]} = #{signe}"
           + " AND "
           + "#{f[0]} = Mid(#{var}, 1, Length(Concat(#{f[0]}, '0')) - 1))"
           + " OR "
    }

    ssql
  end

  def buscar_brain(apunts)
    busca = []
    wkey = 0
 
    apunts.each_with_index { |a, idx|
      signe = a.deure != 0 ? 1 : 0
      ssql = construir_filtre_apunts(a.ctcte, signe)

      wkey = idx
      busca.delete_if { |i| i.conta < 2 } if wkey != idx

      Brain.where(ssql).each { |b|
        if busca.empty?
          busca.push(
          {
            :wkey => idx,   
            :brakey => b.brakey,
            :bracon => b.bracon,
            :conta => 1
          }
        else
          busca.map! { |i|
            if i[:wkey] == idx && i['brakey'] == b.brakey
              i.conta = i.conta + 1
            end
          }
        end
      }
    }
  end
end
