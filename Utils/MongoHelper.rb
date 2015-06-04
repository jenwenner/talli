class MongoHelper

  def initialize(host,port,db)
    @client = MongoClient.new(host, port)
    @db = @client.db(db)
  end

  def modify(collection,id,payload)
    coll = @db.collection(collection)
    coll.update({:product_id => id},payload,{:upsert => true})
  end

end