module Bling
  InvalidEnvironmentError = Class.new(StandardError)

  class BlingError < StandardError
    attr_reader :data

    def initialize data
      @data = data
    end

    def message
      data['msg']
    end

    def code
      data['cod']
    end
  end

  class BlingObjectNotFound < BlingError
  end
end
