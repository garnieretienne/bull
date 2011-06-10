require 'mongo'

module Bull

  class Database

  @@db = nil
  @@auth = true
  @@index_verified = false

    def self.connect(options)
      server      = options[:server]
      port        = options[:port]
      user        = options[:user]
      password    = options[:password]
      database    = options[:database]
      @@db = Mongo::Connection.new(server, port).db(database)
      @@auth = @@db.authenticate(user, password) if !user.nil?
      return @@db
    end

    def self.connected?
      if @@db.class == Mongo::DB then
        return true if @@auth
      else
        return false
      end
    end

    def self.index_verified
      @@index_verified
    end

    def self.indexed?
      raws = {
        :reports => ['monit.server.id',],
      }

      raws.each do |collection, keys| 
        verify_index(collection, keys)
      end
      @@index_verified = true
      return true
    end

    private

    def self.verify_index(collection, keys)
      coll = @@db.collection(collection)
      keys.each do |key|
        found = false
        coll.index_information().values.each do |index|
          found = true if index['key'].keys.first == key
        end
        coll.create_index([[key, Mongo::ASCENDING]]) if !found
      end
    end

  end
end
