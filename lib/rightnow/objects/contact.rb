class RightNow::Objects::Contact < RightNow::RNObject
  attr_accessor :first_name, :last_name, :email

  def initialize(params)
    @type = 'Contact'

    @first_name = params[:first_name]
    @last_name  = params[:first_name]
    @email      = params[:email]
  end

  def body(action)
    soap_envelope(action) do |xml|
      create_contact(xml)
    end
  end

  private

  def create_contact(xml)
    xml.RNObjects('xsi:type' => "object:#{type}", 'xmlns:object' => 'urn:objects.ws.rightnow.com/v1_2', 'xmlns:base' => 'urn:base.ws.rightnow.com/v1_2') do
      # TODO: what if no email is provided?
      xml[:object].Emails do
        xml[:object].EmailList('action' => 'add') do
          xml[:object].Address(email)
          xml[:object].AddressType do
            xml[:base].ID(id: '0')
          end
        end
      end
      xml[:object].Name do
        xml[:object].First(first_name)
        xml[:object].Last(last_name)
      end
    end
    # Q: What do these do again? This is keeping me from moving the RNObjects block out of each method
    xml.ProcessingOptions do
      xml.SuppressExternalEvents('true')
      xml.SuppressRules('true')
    end
  end

end
