module Bling
  class Item
    attr_reader :json

    # Basic
    attr_accessor :codigo, :descricao

    # Valores
    attr_reader :valor_unidade, :vlr_unit, :preco_custo, :desconto_item

    # Other
    attr_reader :quantidade, :qtde
    attr_accessor :un

    attr_accessor :class_fiscal, :tipo, :origem

    def initialize json = {}
      @json = json

      all_variables.each do |attr|
        if json[attr.to_s].present?
          self.send("#{attr}=".to_sym, json[attr.to_s])
        else
          self.send("#{attr}=".to_sym, json[attr.to_s.gsub('_', '').gsub('descontoitem', 'descontoItem')])
        end
      end
    end

    [:valor_unidade, :preco_custo, :desconto_item, :vlr_unit].each do |attr|
      define_method "#{attr}=".to_sym do |value|
        if value.is_a? String
          value = value.to_f
        end

        self.instance_variable_set "@#{attr}".to_sym, value
      end
    end

    def quantidade= value
      if value.is_a? String
        value = value.to_i
      end

      @quantidade = value
    end

    def qtde= value
      if value.is_a? String
        value = value.to_i
      end

      @qtde = value
    end

    def to_post_hash
      hash = {}

      all_variables.each do |attr|
        value = self.send(attr)
        key = attr.to_s

        case attr
        when :valor_unidade
          key = :vlr_unit
        when :quantidade
          key = :qtde
        when :class_fiscal
          key = :class_fiscal
        end

        hash[key] = value
      end

      # { 'item' => hash }
      hash
    end

    def all_variables
      [:codigo, :descricao, :valor_unidade, :preco_custo, :desconto_item, :quantidade, :un, :class_fiscal, :tipo, :origem]
    end
  end
end
