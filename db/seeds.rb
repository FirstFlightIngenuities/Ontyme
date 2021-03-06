# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create([{user_id2: "1"}, {user_id2: "2"}, {user_id2: "3"}])
Driver.create([{driver_id2: "1"}, {driver_id2: "2"}, {driver_id2: "3"}, {driver_id2: "4"}, {driver_id2: "5"}])
DriverCurrentStatus.create([{driver_id2: "1", status: "Offline", trip_status: "available", override: 0}, {driver_id2: "2", status: "Offline", trip_status: "available", override: 0}, {driver_id2: "3", status: "Offline", trip_status: "available", override: 0}, {driver_id2: "4", status: "Offline", trip_status: "available", override: 0}, {driver_id2: "5", status: "Offline", trip_status: "available", override: 0}])