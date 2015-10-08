module Bling
  class Base
    attr_reader :json

    def self.all
      elements = []
      response = nil

      page = 0
      while response.nil? or response['retorno']['erros'].blank?
        page += 1

        response = Bling.get("#{path}/page=#{page}/")
        break if response['retorno']['erros'].present?

        response['retorno'][path].each do |p|
          elements.push self.new(p[object_type])
        end
      end

      elements
    end

    def self.find id
      response = Bling.get("#{object_type}/#{id}/")

      unless response['retorno']['erros'].present?
        self.new response['retorno'][path].first[object_type]
      else
        raise_error_from_response response, BlingObjectNotFound
      end
    end

    def reload
      self.class.find self.object_identifier
    end

    def self.create hash = {}
      element = self.new

      hash.each do |k, v|
        if element.respond_to? "#{k}="
          element.send("#{k}=", v)
        end
      end

      element.create nil, hash[:gerarnfe]
    end

    def create hash = nil, gerarnfe = nil
      raise BlingError.new({'msg' => "#{self.error_variable.capitalize} não pode ficar em branco."}) unless self.can_create?

      hash ||= self.to_post_hash

      response = Bling.post("#{self.class.object_type}", hash, gerarnfe)

      unless response['retorno']['erros'].present?
        self.update_identifier(response) if self.respond_to? :update_identifier
        self.reload
      else
        raise_error_from_response response
      end
    end

    def self.delete id
      response = Bling.delete("#{object_type}/#{id}/")

      unless response['retorno']['erros'].present?
        true
      else
        raise_error_from_response response
      end
    end

    def delete
      self.class.delete self.codigo
    end

    def self.raise_error_from_response response, type = BlingError
      raise type.new(get_error_from_response response)
    end

    def raise_error_from_response response
      self.class.raise_error_from_response response
    end

    def self.get_error_from_response response
      errors = response['retorno']['erros']
      value = nil

      if errors.is_a? Array
        value = errors.first['erro']
      elsif errors.is_a? Hash
        if errors['erro'].present?
          value = errors['erro']
        else
          value = errors
        end
      end


      if value['msg'].present?
        value
      else
        value['msg'] = value[value.keys.first]
      end

      value
    end

    def get_error_from_response response
      self.class.get_error_from_response response
    end

    def can_create?
      true
    end
  end
end
