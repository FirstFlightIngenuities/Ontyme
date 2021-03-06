class CreateCompletedTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :completed_trips do |t|
        t.text :completed_trip_id2
        t.string :user_id2, foreign_key: true
        t.string :driver_id2, foreign_key: true
        t.text :trip_request_id2, foreign_key: true
        t.text :active_trip_id2, foreign_key: true
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
        t.datetime :completed_trip_end_time
        t.string :status
        t.float :total_miles
        t.string :payment_status
      t.timestamps
    end
  end
end
