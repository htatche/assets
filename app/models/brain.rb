class Brain < ActiveRecord::Base
  @@my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  
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

  def self.construir_filtre_apunts(emplos, compte, signe)
    var = compte[0, compte.length - emplos.to_i]
    ssql = ""
    fields = [
      ['braori', 'brapor'],
      ['brades', 'brapde'],
      ['braimp','braipr'],
      ['brapag', 'braipa'],
      ['brareb', 'braire']
    ]

    fields.each_with_index { |f, idx|
      #ssql = "#{f[1]} = #{signe} AND #{f[0]} = "
      #       "Mid(#{var}, 1, Length(Concat(#{f[0]}, '0')) - 1)) OR"

      ssql = ssql + "#{f[1]} = #{signe}
             AND 
            #{f[0]} = substr('#{var}', 1, Length(Concat(#{f[0]}, '0')) - 1)"

      ssql = ssql + " OR " unless idx == fields.length-1
    }

    ssql
  end

  def self.buscar_brain(emplos, apunts)
    busca = []
    wkey = 0
 
    apunts.each_with_index { |a, idx|
      @@my_logger.debug "Apunt: #{idx}, wkey: #{wkey}"

      a = a[1]
      signe = a['deure'] != 0 ? 1 : -1
      ssql = construir_filtre_apunts(emplos, a['ctcte'], signe)

      busca.delete_if { |i| i[:conta] < 2 } if busca.any? && wkey != idx

      Brain.where(ssql).each_with_index { |b, bidx|
        @@my_logger.debug "Brain: #{bidx}, brakey: #{b.brakey}"

        if busca.empty?
          busca.push (
            {
              :wkey => idx,   
              :brakey => b.brakey,
              :bracon => b.bracon,
              :conta => 1
            }
          )
        else
          busca.each { |i|
            if i[:wkey] == idx && i[:brakey] == b.brakey
              i[:conta] = i[:conta] + 1
            end
          } 
        end
        
        @@my_logger.debug busca.to_yaml
      }

      wkey = idx
    }

    @@my_logger.info "Borrem els conta <2..."
    busca.delete_if { |i| i[:conta] < 2 }
    @@my_logger.debug busca.to_yaml
    return busca
  end
end
