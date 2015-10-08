module Bling
  class Cliente
    attr_reader :json

    # Basic
    attr_accessor :nome, :email

    # Address
    attr_accessor :endereco, :numero, :complemento, :cidade, :bairro, :cep, :uf

    # Extra
    attr_accessor :cnpj, :cpf, :cpf_cnpj, :ie, :rg, :ie_rg, :tipo_pessoa, :fone

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
        when :ie_rg
          key = 'ie_rg'
        when :cpf_cnpj
          key = 'cpf_cnpj'
        end

        hash[key] = value
      end

      hash
    end

    def all_variables
      [:nome, :email, :endereco, :numero, :complemento, :cidade, :bairro, :cep, :uf, :cnpj, :cpf, :ie, :rg, :tipo_pessoa, :fone]
    end
  end
end
