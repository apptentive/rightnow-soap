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
    # Request.call(:batch, xml: soap_envelope { object.body(:create) } )
    # Request.call(:create, object, self)
    # Response.process do

    # end

    r = connection.call(:batch, xml: soap_envelope { object.body(:create) } )

    # batch requests return an array of request items
    # will this only catch if the first one errors out?
    # what if the last one errors out?
    response_items = r.body[:batch_response][:batch_response_item]
    if error = response_items[0][:request_error_fault]
      raise RightNow::InvalidObject.new(error[:exception_message])
    end

    a = response_items[1][:get_response_msg][:rn_objects_result][:rn_objects]
    object.create_from_response(a)
  end

  def update(object)
    r = connection.call(:batch, xml: soap_envelope { object.body(:update) } )
    response_items = r.body[:batch_response][:batch_response_item]
    # if error = response_items[0][:request_error_fault]
    #   raise RightNow::InvalidObject.new(error[:exception_message])
    # end

    a = response_items[1][:get_response_msg][:rn_objects_result][:rn_objects]

    object.create_from_response(a)
  end

  def find(object)
    r = connection.call(:query_objects, xml: soap_envelope { object.body(:find) } )
    return nil if r.body[:query_objects_response][:result][:paging][:returned_count].to_i == 0
    a = r.body[:query_objects_response][:result][:rn_objects_result][:rn_objects]
    object.create_from_response(a)
  end

  private

  def soap_envelope
    Nokogiri::XML::Builder.new do |xml|
      xml[:env].Envelope('xmlns:env' => 'http://schemas.xmlsoap.org/soap/envelope/') do
        xml[:env].Header do
          xml[:message].ClientInfoHeader('xmlns:message' => 'urn:messages.ws.rightnow.com/v1_2', 'xmlns' => 'urn:messages.ws.rightnow.com/v1_2', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema') do
            xml.AppID('Apptentive Integration')
          end
          xml[:wsse].Security('xmlns:wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', 'env:mustUnderstand' => '1') do
            xml[:wsse].UsernameToken do
              xml[:wsse].Username(username)
              xml[:wsse].Password(password, 'Type' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText')
            end
          end
        end
        xml[:env].Body('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema') do
          xml << yield
        end
      end
    end.doc.root.to_xml
  end
end

class RightNow::InvalidClient < StandardError; end
class RightNow::InvalidObject < StandardError; end
