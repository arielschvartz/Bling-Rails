module Bling
  class NotaFiscal < Bling::Base
    # Basic
    attr_accessor :serie, :numero, :numero_pedido_loja, :situacao

    # Valores
    attr_reader :valor_nota

    # Links
    attr_accessor :xml, :link_danfe

    # Data
    attr_reader :data_emissao

    # Other
    attr_accessor :contato, :vendedor, :chave_acesso, :codigos_rastreamento

    def initialize json = {}
      @json = json

      [:serie, :numero, :numero_pedido_loja, :situacao, :valor_nota, :xml, :link_danfe, :data_emissao, :contato, :vendedor, :chave_acesso, :codigos_rastreamento].each do |attr|

        parts = attr.to_s.split('_')
        if parts.length > 1
          parts[-1] = parts.last.capitalize
        end

        self.send("#{attr}=".to_sym, json[parts.join('')])
      end
    end

    def valor_nota= value
      if value.is_a? String
        value = value.to_f
      end

      @valor_nota = value
    end

    def data_emissao= value
      if value.is_a? String
        value = Time.zone.parse(value)
      end

      @data_emissao = value
    end

    def self.path
      "notasfiscais"
    end

    def self.object_type
      "notafiscal"
    end

    def object_identifier
      "#{self.numero}/#{self.serie}"
    end

    def self.find numero, serie = nil
      if serie.nil?
        super
      else
        super "#{numero}/#{serie}"
      end
    end
  end
end
