class CreateTripRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :trip_requests do |t|
        t.text :trip_request_id2
        t.string :user_id2, foreign_key: true
        t.string :map_provider
        t.text :map_provider_url
        t.string :destination_street
        t.string :destination_city
        t.string :destination_state
        t.string :destination_postalcode
        t.string :destination_longitude
        t.string :destination_latitude
        t.text :map_provider_destination_id
        t.text :map_provider_destination_slug
        t.string :pickup_street
        t.string :pickup_city
        t.string :pickup_state
        t.string :pickup_postalcode
        t.string :pickup_longitude
        t.string :pickup_latitude
        t.text :map_provider_pickup_id
        t.text :map_provider_pickup_slug
        t.string :status
        t.timestamps
    end
  
    add_index :trip_requests, :trip_request_id2, unique: true

  end
end
