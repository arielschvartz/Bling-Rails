module Bling
  class Cliente
    attr_reader :json

    # Basic
    attr_accessor :nome, :email

    # Address
    attr_accessor :endereco, :numero, :complemento, :cidade, :bairro, :cep, :uf

    # Extra
    attr_accessor :cnpj, :ie, :rg, :tipo_pessoa

    def initialize json = {}
      @json = json

      all_variables.each do |attr|
        if json[attr.to_s].present?
          self.send("#{attr}=".to_sym, json[attr.to_s])
        else
          self.send("#{attr}=".to_sym, json[attr.to_s.gsub('_', '')])
        end
      end
    end

    def to_post_hash
      hash = {}
      all_variables.each do |attr|
        value = self.send(attr)
        key = attr.to_s

        case attr
        when :tipo_pessoa
          key = attr.to_s.camelize(:lower)
        end

        hash[key] = value
      end

      hash
    end

    def all_variables
      [:nome, :email, :endereco, :numero, :complemento, :cidade, :bairro, :cep, :uf, :cnpj, :ie, :rg, :tipo_pessoa]
    end
  end
end
