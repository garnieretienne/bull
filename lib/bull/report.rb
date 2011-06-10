require 'crack/xml'
require 'mongo'
require 'bull/event'

# 
module Bull
  # 
  class Report

    attr_reader :timestamp, :events

    # Create a report from xml or bson
    # From xml datas:
    #   report = Bull::Report.new(:xml => data)
    # From bson
    #   report = Bull::Report.new(:bson => data)
    def initialize(report)
      if report[:xml] then
        @data = Crack::XML.parse(report[:xml])     
      elsif report[:bson]
        @data = report[:bson]
        @timestamp = @data["_id"].generation_time.to_i
        @services = Hash.new
        link_services
        @events = Array.new
        link_events
      end
    end

    # Save report in a MongoDB collection called 'reports'
    #   db = Mongo::Connection.new('server', port).db('database')
    #   report = Bull::Report::new(:xml => data)
    #   report.save
    def save(db)
      collection = db.collection("reports")
      collection.insert(@data)
    end

    # Get a value from a bson
    # Return 'N/A' if the keys doesn't exist
    # Get raw data:
    #   report.get(:data => ['key1', 'key2'])
    # Get system data
    #   report.get(:system => ['key1', 'key2', 'key3'])
    # Get a service data
    #   report.services(3).each do |filesystem| # for each services with type 3 (filesystem)
    #     report.get(filesystem => ['key1', 'key2'])
    #   end
    #   
    def get(hash)
      value = case hash.keys.first.to_s
        when 'data' then @data
        when 'system' then @system
        else hash.keys.first
      end
      keys = hash.values.first
      keys.each do |key|
        value = value[key] if !value.nil?
        return 'N/A' if value.nil?
      end
      return value
    end

    # Return a list of type services
    # Monit services types:
    # - 0: filesystem
    # - 1: directory
    # - 2: file
    # - 3: process
    # - 4: host
    # - 5: system
    def services(type)
      return @services[type.to_s]
    end

    private

    # Index all services monitored in the report
    # build the @service[type] array for each type of services monitored
    def link_services
      # Verify the number of declared services
      if @data["monit"]["service"].class == Array then
        @data["monit"]["service"].each do |service|
          if service['type'] == '5' then
            @system = service
          else
            if @services[service['type']] then
              @services[service['type']] << service
            else
             @services[service['type']] = Array.new
             @services[service['type']] << service
            end
          end
        end
      else
        @system = @data["monit"]["service"]
      end
    end

    # Index all events
    # build the @events array
    def link_events
      @services.values.each do |type|
        type.each do |service|
          @events << "#{service['name']}: #{service['status_message']} (#{Bull::Monit::Event.message(service['status'].to_i, service['status_hint'].to_i)})" if service['status'] != '0'
        end
      end
    end

  end
end

