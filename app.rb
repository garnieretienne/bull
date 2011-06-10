require 'sinatra/base'
require File.expand_path(File.dirname(__FILE__) + "/lib/bull")
require 'bull/database'
require 'bull/report'

module Bull

  class Server < Sinatra::Base

    # Application configuration
    configure do
      set :configs => 'config'
      set :public  => 'public'

      # Select environment
      cfg_environment = YAML.load_file( settings.configs + "/environment.yml")
      cfg_environment.each_pair do |key, value|
        set(key.to_sym, value)
      end
      
      # Configure application
      cfg_application = YAML.load_file( settings.configs + "/application.yml")[settings.environment.to_s]
      cfg_application.each_pair do |key, value|
        set(key.to_sym, value)
      end

      # Configure collector
      cfg_collector = YAML.load_file( settings.configs + "/collector.yml")[settings.environment.to_s]
      if cfg_collector then
        cfg_collector.each_pair do |key, value|
          set(key.to_sym, value)
        end
      end

      # Configure database
      cfg_database = YAML.load_file( settings.configs + "/database.yml")[settings.environment.to_s]
      if cfg_database then
        cfg_database.each_pair do |key, value|
          set(key.to_sym, value)
        end
      end
    end

    # Configure some helpers
    helpers do

      # convert time (s) into string
      def time_to_s(time)
        years   = time / 31104000
        days    = (time - (years * 31104000)) / 86400
        hours   = (time - years * 31104000 - days * 86400) / 3600
        value = ''
        value += "#{years} years" if years != 0
        value += "#{days} days" if days != 0
        value += "#{hours} hours"
      end

      # convert KB to string
      def kb_to_s(kb)
        case kb
          when 0..1048576
            mb = kb/1024.to_f
            return "#{mb.round(2)} MB"
          else
            gb = kb/( 1024 * 1024 ).to_f
            return "#{gb.round(2)} GB"
        end
      end

      def protected!
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        if settings.collector_user.nil? then
          return true
        else
          @auth ||=  Rack::Auth::Basic::Request.new(request.env)
          @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.collector_user, settings.collector_password]
        end
      end
    end

    before do
      # Connect to the database if needed
      settings.mongo_server   = 'localhost' if settings.mongo_server.nil?
      settings.mongo_port     = '27017' if settings.mongo_port.nil?
      settings.mongo_database = 'bull' if settings.mongo_database.nil?
      DB = Bull::Database.connect(
        :server   => settings.mongo_server,
        :port     => settings.mongo_port,
        :user     => settings.mongo_user,
        :password => settings.mongo_password,
        :database => settings.mongo_database,
    ) if !Bull::Database.connected?
      Bull::Database.indexed? if !Bull::Database.index_verified
    end

    # M/Monit XML grabber
    post '/collector' do
      protected!
      request.body.rewind
      data = request.body.read
      report = Bull::Report.new(:xml => data)
      report.save(DB)
    end

    # Root
    get '/' do
      redirect '/hosts'
    end

    # List alls hosts founded in the reports
    get '/hosts' do
      collection = DB.collection("reports")
      @reports = Array.new
      # Select last report for each host
      collection.distinct('monit.server.id').each do |host|
        bson_report = collection.find({"monit.server.id" => host}).sort("_id", -1).limit(1).first
        report = Bull::Report.new(:bson => bson_report)
        @reports << report
      end
      haml :index
    end
    
    # Show host detail
    get '/host/:id/:hostname' do
      collection = DB.collection("reports")
      bson_report = collection.find({"monit.server.id" => params[:id]}).sort("_id", -1).limit(1).first
      @report = Bull::Report.new(:bson => bson_report)
      haml :show
    end

  end
end
