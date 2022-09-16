class RightNow::Objects::Incident < RightNow::RNObject
  class Thread
    attr_accessor :id, :display_order, :text

    def initialize(params)
      @id            = params[:id]
      @display_order = params[:display_order]
      @text          = params[:text]
    end
  end

  attr_accessor :primary_contact_id,
    :message,
    :id,
    :subject,
    :threads,
    :app_id,
    :from_agent,
    :status_id,
    :queue_id,
    :channel_id

  def initialize(params)
    @type = "Incident"

    # update and building response
    @id                 = params[:id] # rubocop:disable Layout/SpaceAroundOperators

    # create
    @app_id             = params[:app_id]
    @subject            = params[:subject]
    @primary_contact_id = params[:contact_id]

    # create and update
    @message            = params[:message]
    @status_id          = params[:status_id]
    @queue_id           = params[:queue_id]
    @channel_id         = params[:channel_id]
    @from_agent         = !!params[:from_agent]

    # when building a response object
    @threads            = params[:threads] || [] # rubocop:disable Layout/SpaceAroundOperators
  end

  def self.create_from_response(incident_params)
    RightNow::Objects::Incident.new(
      id: incident_params[:id][:@id],
      threads: (build_threads(incident_params[:threads][:thread_list]) if incident_params[:threads]),
      subject: incident_params[:subject]
    )
  end

  def body(action)
    case action
    when :create
      validate_incident
      incident_modification_wrapper { create_incident }
    when :update
      incident_modification_wrapper { update_incident }
    when :find
      find_incident
    end
  end

  def most_recent_thread
    threads.max_by { |thread| thread.display_order.to_i }
  end

  private

  def validate_incident
    raise RightNow::InvalidObjectError, "Incidents must be created with an Apptentive app_id" unless app_id?
  end

  def app_id?
    app_id && !app_id.strip.empty?
  end

  def self.build_threads(thread_list)
    [thread_list].flatten.map do |raw|
      Thread.new(id: raw[:id][:@id], display_order: raw[:display_order], text: raw[:text])
    end
  end

  private_class_method :build_threads

  # building XML for this object feels like a different responsibility
  # where would it go?
  def incident_modification_wrapper
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml[:message].Batch("xmlns:message" => "urn:messages.ws.rightnow.com/v1_4") do
        xml[:message].BatchRequestItem do
          xml << yield
        end
        xml[:message].BatchRequestItem do
          xml[:message].GetMsg do
            xml[:message].RNObjects("xmlns:object" => "urn:objects.ws.rightnow.com/v1_4", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:type" => "object:Incident") do
              xml.ID("xmlns" => "urn:base.ws.rightnow.com/v1_4", "xsi:type" => "ChainDestinationID", "id" => "0", "variableName" => "MyIncident")
              xml[:object].Threads
            end
            xml[:message].ProcessingOptions do
              xml[:message].FetchAllNames("false")
            end
          end
        end
      end
    end.doc.root.to_xml
  end

  def create_incident
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml[:message].CreateMsg("xmlns:message" => "urn:messages.ws.rightnow.com/v1_4") do
        xml[:message].RNObjects("xsi:type" => "object:Incident", "xmlns:object" => "urn:objects.ws.rightnow.com/v1_4", "xmlns:base" => "urn:base.ws.rightnow.com/v1_4") do
          xml[:base].ID("xmlns:base" => "urn:base.ws.rightnow.com/v1_4", "xsi:type" => "ChainSourceID", "id" => "0", "variableName" => "MyIncident")
          if channel_id
            # 9 - Email
            xml[:object].Channel do
              xml[:base].ID(id: channel_id)
            end
          end
          xml[:object].CustomFields do
            xml.GenericFields("name" => "c", "dataType" => "OBJECT", "xmlns" => "urn:generic.ws.rightnow.com/v1_4") do
              xml.DataValue do
                xml.ObjectValue do
                  xml.GenericFields("name" => "apptentive_app_id", "dataType" => "STRING") do
                    xml.DataValue do
                      xml.StringValue(app_id)
                    end
                  end
                end
              end
            end
          end
          xml[:object].PrimaryContact do
            xml[:object].Contact do
              xml[:base].ID(id: primary_contact_id)
            end
          end
          if queue_id
            xml[:object].Queue do
              xml[:base].ID(id: queue_id)
            end
          end
          if status_id
            xml[:object].StatusWithType do
              xml[:object].Status do
                xml[:base].ID(id: status_id)
              end
            end
          end
          xml[:object].Subject(subject)
          # NOTE: what if there is a nil or blank message sent to Oracle?
          xml[:object].Threads do
            xml[:object].ThreadList(action: "add") do
              if channel_id
                # 9 - Email
                xml[:object].Channel do
                  xml[:base].ID(id: channel_id)
                end
              end
              xml[:object].EntryType do
                xml[:base].ID(id: 3)
              end
              xml[:object].Text(message)
            end
          end
        end

        xml[:message].ProcessingOptions do
          xml[:message].SuppressExternalEvents("false")
          xml[:message].SuppressRules("false")
        end
      end
    end.doc.root.to_xml
  end

  def update_incident
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml[:message].UpdateMsg("xmlns:message" => "urn:messages.ws.rightnow.com/v1_4") do
        xml[:message].RNObjects("xsi:type" => "object:Incident", "xmlns:object" => "urn:objects.ws.rightnow.com/v1_4", "xmlns:base" => "urn:base.ws.rightnow.com/v1_4") do
          xml[:base].ID(id: id, "xsi:type" => "ChainSourceID", "variableName" => "MyIncident")
          if queue_id
            xml[:object].Queue do
              xml[:base].ID(id: queue_id)
            end
          end
          if status_id
            xml[:object].StatusWithType do
              # 1 - Unresolved
              # 2 - Resolved
              # 3 - Waiting for Customer
              xml[:object].Status do
                xml[:base].ID(id: status_id)
              end
            end
          end
          xml[:object].Threads do
            xml[:object].ThreadList(action: "add") do
              if channel_id
                # 9 - Email
                xml[:object].Channel do
                  xml[:base].ID(id: channel_id)
                end
              end
              xml[:object].EntryType do
                # if an agent is responding from Apptentive dashboard, it needs to be 2 (Staff Account)
                # 1 - Note
                # 2 - Staff Account
                # 3 - Customer
                # 4 - Customer Proxy
                # 5 - Chat
                # 6 - Rule Response
                # 7 - Rule Response Template
                # 8 - Voice Integration

                # TODO: flip this based on who is sending the notification
                xml[:base].ID(id: entry_type)
              end
              xml[:object].Text(message)
            end
          end
        end

        xml[:message].ProcessingOptions do
          xml[:message].SuppressExternalEvents("false")
          xml[:message].SuppressRules("false")
        end
      end
    end.doc.root.to_xml
  end

  def find_incident
    Nokogiri::XML::Builder.new(encoding: "UTF-8") do |xml|
      xml.QueryObjects("xmlns" => "urn:messages.ws.rightnow.com/v1_4") do
        xml.Query("SELECT Incident FROM Incident i WHERE i.ID = #{id}")
        xml.ObjectTemplates("xmlns:object" => "urn:objects.ws.rightnow.com/v1_4", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:type" => "object:Incident") do
          xml[:object].Threads
        end
        xml.PageSize("100")
      end
    end.doc.root.to_xml
  end

  def entry_type
    from_agent ? 2 : 3
  end
end
