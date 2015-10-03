module Bling
  class Parcela
    attr_reader :json

    # Valores
    attr_reader :valor

    # Data
    attr_reader :data_vencimento

    # Other
    attr_accessor :obs

    def initialize json = {}
      @json = json

      [:valor, :data_vencimento, :obs].each do |attr|
        self.send("#{attr}=".to_sym, json[attr.to_s.gsub('_', '').gsub('datavencimento', 'dataVencimento')])
      end
    end

    def valor= value
      if value.is_a? String
        value = value.to_f
      end
      @valor = value
    end

    def data_vencimento= value
      if value.is_a? String
        value = Time.zone.parse(value)
      end
      @data_vencimento = value
    end
  end
end
