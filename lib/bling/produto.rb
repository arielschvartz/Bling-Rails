module Bling
  class Produto < Bling::Base
    # Basic
    attr_accessor :codigo, :descricao

    # Valores
    attr_reader :preco, :preco_custo

    # Peso
    attr_reader :peso_liq, :peso_bruto

    # Estoque
    attr_reader :estoque_minimo, :estoque_maximo

    # Dimensões
    attr_reader :largura_produto, :altura_produto, :profundidade_produto

    # Data
    attr_reader :data_inclusao, :data_alteracao

    # Other
    attr_accessor :unidade, :gtin, :gtin_embalagem, :image_thumbnail, :descricao_complementar

    # Para o Cadastro
    attr_accessor :class_fiscal, :origem, :estoque, :error_variable

    def initialize json = {}
      @json = json

      all_variables.each do |attr|
        self.send("#{attr}=".to_sym, json[attr.to_s.camelize(:lower)])
      end
    end

    [:preco, :preco_custo, :peso_liq, :peso_bruto, :largura_produto, :altura_produto, :profundidade_produto].each do |attr|
      define_method "#{attr}=".to_sym do |value|
        if value.is_a? String
          value = value.to_f
        end

        self.instance_variable_set "@#{attr}".to_sym, value
      end
    end

    [:estoque_minimo, :estoque_maximo].each do |attr|
      define_method "#{attr}=".to_sym do |value|
        if value.is_a? String
          value = value.to_i
        end

        self.instance_variable_set "@#{attr}".to_sym, value
      end
    end

    [:data_inclusao, :data_alteracao].each do |attr|
      define_method "#{attr}=".to_sym do |value|
        if value.is_a? String
          value = Time.zone.parse(value)
        end

        self.instance_variable_set "@#{attr}".to_sym, value
      end
    end

    def origem= value
      if value.is_a? Fixnum or value.is_a? Integer or value.is_a? Float
        value = value.to_s
      end
      @origem = value
    end

    def create hash = nil
      raise BlingError.new({'msg' => "Origem não é válida."}) unless self.valid_code?

      begin
        self.class.find self.codigo
        raise BlingError.new({'msg' => "Já existe um produto com esse código."})
      rescue BlingObjectNotFound => e
        super
      end
    end

    def self.update codigo, hash = {}
      p = self.find codigo

      hash.each do |k, v|
        if p.respond_to? "#{k}="
          p.send("#{k}=", v)
        end
      end

      p.update
    end

    def update hash = nil
      raise BlingError.new({'msg' => "#{self.error_variable.capitalize} não pode ficar em branco."}) unless self.can_create?

      raise BlingError.new({'msg' => "Origem não é válida."}) unless self.valid_code?

      hash ||= self.to_post_hash
      response = Bling.put("#{self.class.object_type}/#{self.codigo}", hash)

      unless response['retorno']['erros'].present?
        self.reload
      else
        raise_error_from_response response
      end
    end

    def to_post_hash
      hash = {}

      (all_variables + register_variables).each do |attr|
        value = self.send(attr)
        key = key = attr.to_s

        case attr
        when :descricao_complementar, :gtin_embalagem, :estoque_minimo, :estoque_maximo
          key = attr.to_s.camelize(:lower)
        when :preco
          key = 'vlr_unit'
        when :largura_produto, :altura_produto, :profundidade_produto
          key = attr.to_s.split('_').first
        when :unidade
          key = 'un'
        end

        hash[key] = value
      end

      { self.class.object_type => hash }
    end

    def self.possible_origins
      {
        '0' => 'Nacional, exceto as indicadas nos códigos 3, 4, 5 e 8',
        '1' => 'Estrangeira - Importação direta, exceto a indicada no código 6',
        '2' => 'Estrangeira - Adquirida no mercado interno, exceto a indicada no código 7',
        '3' => 'Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40% e inferior ou igual a 70%',
        '4' => 'Nacional, cuja produção tenha sido feita em conformidade com os processos produtivos básicos de que tratam as legislações citadas nos Ajustes',
        '5' => 'Nacional, mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40%',
        '6' => 'Estrangeira - Importação direta, sem similar nacional, constante em lista da CAMEX',
        '7' => 'Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista da CAMEX',
        '8' => 'Nacional, mercadoria ou bem com Conteúdo de Importação superior a 70%'
      }
    end

    def self.path
      "produtos"
    end

    def self.object_type
      "produto"
    end

    def object_identifier
      self.codigo
    end

    def all_variables
      [:codigo, :descricao, :preco, :preco_custo, :peso_liq, :peso_bruto, :estoque_minimo, :estoque_maximo, :largura_produto, :altura_produto, :profundidade_produto, :data_inclusao, :data_alteracao, :unidade, :gtin, :gtin_embalagem, :image_thumbnail, :descricao_complementar]
    end

    def register_variables
      [:class_fiscal, :origem, :estoque]
    end

    def can_create?
      [:codigo, :descricao, :preco].each do |attr|
        if self.send(attr).nil?
          self.error_variable = attr
          return false
        end
      end

      true
    end

    def valid_code?
      return true if self.origem.blank?

      if self.class.possible_origins.keys.include? self.origem
        true
      elsif self.class.possible_origins.values.include? self.origem
        true
      else
        false
      end
    end
  end
end
