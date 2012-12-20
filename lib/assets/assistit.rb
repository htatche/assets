module Assistit
  def errorPresenter(index)
    err = []

    valid?
    if errors.any?
      errors.messages.each { |i|
        i[1].each { |j|
          field = validationTitle + ' ('+index.to_s+') ' + i[0].to_s
          err << {:field => field, :msg => j}
        }
      }
    end

    err
  end

end


