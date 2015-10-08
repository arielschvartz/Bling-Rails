require 'httparty'
require 'dotenv'
Dotenv.load

require "bling/engine"
require "bling/version"
require "bling/exceptions"

require "bling/base"
require "bling/cliente"
require "bling/item"
require "bling/nota_fiscal"
require "bling/parcela"
require "bling/pedido"
require "bling/produto"

module Bling
  class << self
    attr_accessor :encoding
    attr_accessor :environment
  end

  self.encoding = "UTF-8"
  self.environment = :production

  def self.uris
    @uris ||= {
      production: {
        api: 'https://bling.com.br/Api/v2/'
      },
      sandbox: {
        api: 'https://bling.com.br/Api/v2/'
      }
    }
  end

  def self.root_uri type = :api
    root = uris.fetch(environment.to_sym) { raise InvalidEnvironmentError }
    root[type]
  end

  def self.api_url path, type = :api
    File.join root_uri(type), path
  end

  def self.get path
    HTTParty.get "#{api_url(path)}/json/", query: { apikey: ENV['BLING_API_KEY'] }
  end

  def self.post path, body = nil, gerarnfe = nil
    unless body.is_a? Hash
      body = {}
    end

    xml = nil
    if body['pedido']
      xml = body['pedido'].to_xml(root: 'pedido', dasherize: false).gsub('iten>', 'item>')
    elsif body['produto']
      xml = body['produto'].to_xml(root: 'produto', dasherize: false)
    elsif body['']
    end

    options = {
      query: {
        apikey: ENV['BLING_API_KEY']
      },
      body: {
        xml: xml
      }
    }

    if gerarnfe
      options[:body].merge! gerarnfe: 'true'
    end

    if Rails.env.development?
      puts options
    end

    response = HTTParty.post api_url(path), options

    if Rails.env.development?
      puts "Corpo da resposta: #{response.body}"
      puts "Corpo do envio: #{response.request.options[:body]}"
    end

    response
  end

  def self.put path, body = nil
    unless body.is_a? Hash
      body = {}
    end

    HTTParty.post api_url(path), query: { apikey: ENV['BLING_API_KEY'] }, body: { xml: body.to_xml(dasherize: false) }
  end

  def self.delete path
    HTTParty.delete api_url(path), query: { apikey: ENV['BLING_API_KEY'] }
  end


end
