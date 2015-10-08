module Bling
  class Pedido < Bling::Base
    # Basic
    attr_reader :numero, :situacao

    # Valores
    attr_reader :desconto, :valor_frete, :total_produtos, :total_venda

    # Observações
    attr_accessor :observacoes, :observacao_interna

    # Data
    attr_reader :data

    # Other
    attr_accessor :vendedor
    attr_reader :cliente, :itens, :parcelas

    def initialize json = {}
      @json = json

      all_variables.each do |attr|
        self.send("#{attr}=".to_sym, json[attr.to_s.gsub('_', '')])
      end
    end

    def data= value
      if value.is_a? String
        value = Time.zone.parse(value)
      end
      @data = value
    end

    def numero= value
      if value.is_a? String
        value = value.to_i
      end

      @numero = value
    end

    [:desconto, :valor_frete, :total_produtos, :total_venda].each do |attr|
      define_method "#{attr}=".to_sym do |value|
        if value.is_a? String
          value = value.to_f
        end

        self.instance_variable_set "@#{attr}".to_sym, value
      end
    end

    def cliente= value
      return if value.blank?

      @cliente = Cliente.new(value)
    end

    def itens= value
      return unless value.is_a? Array

      @itens = value.map { |i| Item.new(i) }
    end

    def parcelas= value
      return unless value.is_a? Array

      @parcelas = value.map { |p| Parcela.new(p['parcela']) }
    end

    def situacao= value
      if value.is_a? Fixnum or value.is_a? Integer or value.is_a? Float
        value = value.to_s
      end
      @situacao = value
    end

    def situacao_em_codigo
      if self.class.possible_situations.keys.include? self.situacao
        self.situacao
      elsif self.class.possible_situations.values.include? self.situacao
        self.class.possible_situations.invert[self.situacao]
      else
        nil
      end
    end

    def self.update numero, codigo
      p = self.find numero

      unless codigo.is_a? String
        codigo = codigo.to_s
      end
      p.situacao = codigo
      p.update
    end

    def update
      raise BlingError.new({'msg' => "#{self.error_variable.capitalize} não pode ficar em branco."}) unless self.valid_code?

      hash = { self.class.object_type => { 'situacao' => self.situacao_em_codigo } }
      response = Bling.put("#{self.class.object_type}/#{self.numero}", hash)

      unless response['retorno']['erros'].present?
        self.reload
      else
        raise_error_from_response response
      end
    end

    def to_post_hash
      hash = {}

      all_variables.each do |attr|
        value = self.send(attr)
        key = attr.to_s

        case attr
        when :itens
          value = value.map(&:to_post_hash)
        when :cliente
          value = value.to_post_hash
        end

        hash[key] = value
      end

      { self.class.object_type => hash }
    end

    def all_variables
      [:numero, :situacao, :desconto, :valor_frete, :total_produtos, :total_venda, :observacoes, :observacao_interna, :data, :vendedor, :cliente, :itens, :parcelas]
    end

    def self.possible_situations
      {
        '0' => 'Em Aberto',
        '1' => 'Atendido',
        '2' => 'Cancelado',
        '3' => 'Em andamento',
        '4' => 'Venda Agenciada',
        '10' => 'Em digitação',
        '11' => 'Verificado'
      }
    end

    def self.path
      "pedidos"
    end

    def self.object_type
      "pedido"
    end

    def object_identifier
      self.numero
    end

    def object_identifier= value
      self.numero = value
    end

    def update_identifier response
      self.object_identifier = response['retorno']['pedidos']['pedido']['numero']
    end

    def valid_code?
      if self.class.possible_situations.keys.include? self.situacao
        true
      elsif self.class.possible_situations.values.include? self.situacao
        true
      else
        false
      end
    end
  end
end
