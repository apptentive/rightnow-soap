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
    connection.call(:create, xml: soap_envelope(:create) { object.body(:create) } )
  end

  def update(object)
    connection.call(:update, xml: soap_envelope(:update) { object.body(:update) } )
  end

  private

  def soap_envelope(action)
    Nokogiri::XML::Builder.new do |xml|
        xml[:env].Envelope('xmlns:env' => "http://schemas.xmlsoap.org/soap/envelope/") do
          xml[:env].Header do
            xml[:message].ClientInfoHeader('xmlns:message' => "urn:messages.ws.rightnow.com/v1_2", 'xmlns' => "urn:messages.ws.rightnow.com/v1_2", 'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema") do
              xml.AppID('Apptentive Integration')
            end
            xml[:wsse].Security('xmlns:wsse' => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd", "env:mustUnderstand" => "1") do
              xml[:wsse].UsernameToken do
                xml[:wsse].Username(username)
                xml[:wsse].Password(password, 'Type' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText')
              end
            end
          end
          xml[:env].Body('xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance", 'xmlns:xsd' => "http://www.w3.org/2001/XMLSchema") do
            xml.send(action.capitalize, 'xmlns' => "urn:messages.ws.rightnow.com/v1_2") do
              xml << yield
            end
          end
        end
      end.doc.root.to_xml
  end
end

class RightNow::InvalidClient < StandardError; end
