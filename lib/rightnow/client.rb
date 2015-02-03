require 'savon'

class RightNow::Client
  attr_accessor :wsdl, :username, :password, :options
  attr_reader :connection

  def initialize(wsdl, username, password, options = {})
    raise RightNow::InvalidClient unless username && password

    @wsdl       = wsdl
    @username   = username
    @password   = password
    @options    = options

    @connection = Savon.client(
      { wsdl: wsdl }.merge(options)
    )
  end

  def create(object)
    connection.call(:create, xml: object.body(:create))
  end

  def update(object)
    connection.call(:update, xml: object.body(:update))
  end
end

class RightNow::InvalidClient < StandardError; end
