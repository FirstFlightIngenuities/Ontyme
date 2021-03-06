class CreateActiveTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :active_trips do |t|
    	t.text :active_trip_id2
   		t.string :user_id2, foreign_key: true
    	t.string :driver_id2, foreign_key: true
    	t.text :trip_request_id2, foreign_key: true
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
        t.string :pickup_longitude
        t.string :pickup_latitude
        t.datetime :driver_connect_time
        t.datetime :trip_start_time
        t.datetime :trip_end_time
        t.text :response_from_routing_service_seg_1
        t.text :response_from_routing_service_seg_2
        t.text :route_data
        t.integer :status
    	t.timestamps
    end
  end
end
