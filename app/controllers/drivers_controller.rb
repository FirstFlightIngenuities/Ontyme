class DriversController < ApplicationController

	def reset
		count = 0
		DriverCurrentStatus.all.each do |x|
			x.trip_status = "available";
			x.status = "Offline";
			if (x.save)
				count += 1
			end
		end 
		if (count == 5) 
			render plain: "good"
		else
			render plain: "f"
		end
	end


	def show
		@driver = Driver.find_by(driver_id2: params[:id])
		if @driver
			session[:driver_id2] = @driver.driver_id2
			cookies[:driver_id2] = @driver.driver_id2
			render :show
		else
			redirect_to root_path
		end
	end

	def changeCurrentStatus
		driverCurrentStatus = DriverCurrentStatus.find_by(driver_id2: session[:driver_id2]) 
		if driverCurrentStatus
			if (driverCurrentStatus.override == 0)
				driverCurrentStatus.status = params[:status]
				driverCurrentStatus.current_longitude = params[:longitude]
				driverCurrentStatus.current_latitude = params[:latitude]
				if driverCurrentStatus.save
					if (params[:status] == "Offline")
						render plain: "Online"
					else
						render plain: "Offline"
					end
				else
					render plain: "BAD"
				end
			else
				render plain: "BAD"
			end
		else
			render plain: "BAD"
		end
	end


	def checkForRideRequests
		if ((params[:longitude] != "null") && (params[:latitude] != "null"))
			updatePosition(params[:longitude], params[:latitude])
		end
		driverCurrentStatus = DriverCurrentStatus.find_by(driver_id2: session[:driver_id2])
		if (driverCurrentStatus.trip_status == "requesting")
			tripRequest = TripRequest.find_by(trip_request_id2: driverCurrentStatus.trip_request_id2)
			bearing = !!params[:bearing] ? params[:bearing].to_s : nil
			directions = Driver.get_directions(nil, tripRequest.pickup_longitude, tripRequest.pickup_latitude, tripRequest.destination_longitude, tripRequest.destination_latitude, bearing)
			if (tripRequest.status != "cancelled")
				requestData = "data: {\"trip_request_id\" : \""+tripRequest.trip_request_id2+"\", \"destination_street\" : \""+tripRequest.destination_street+"\", \"destination_city\" : \""+tripRequest.destination_city+"\", \"destination_state\" : \""+tripRequest.destination_state+"\", \"destination_postalcode\" : \""+tripRequest.destination_postalcode+"\", \"pickup_street\" : \""+tripRequest.pickup_street+"\", \"pickup_city\" : \""+tripRequest.pickup_city+"\", \"pickup_state\" : \""+tripRequest.pickup_state+"\", \"pickup_postalcode\" : \""+tripRequest.pickup_postalcode+"\"}!#{driverCurrentStatus.current_longitude},#{driverCurrentStatus.current_latitude},#{tripRequest.pickup_longitude},#{tripRequest.pickup_latitude},#{tripRequest.destination_longitude},#{tripRequest.destination_latitude}!#{directions}\n\n"
				render plain: requestData, :content_type => "text/event-stream"
			else
				render plain: "retry: 1500\ndata: cancelled\n\n", :content_type => "text/event-stream"
			end
		else
			render plain: "retry: 1500\ndata: null\n\n", :content_type => "text/event-stream"
		end
	end

	def logTripCoordinates
		activeTrip = ActiveTrip.find_by(driver_id2: session[:driver_id2], status: 1, trip_request_id2: params[:trip_request_id2].to_s)
		routeData = activeTrip.route_data
		routeDataTemp = routeData + params[:coordinates].to_s + ","
		activeTrip.route_data = routeDataTemp
		if (activeTrip.save!)
			requestData = "data: ok\n\n"
			render plain: requestData, :content_type => "text/event-stream"
		else
			requestData = "data: bad\n\n"
			render plain: requestData, :content_type => "text/event-stream"
		end
	end


	def updatePosition(long, lat)
		driverCurrentStatus = DriverCurrentStatus.find_by(driver_id2: session[:driver_id2])
		driverCurrentStatus.current_longitude = long
		driverCurrentStatus.current_latitude = lat
		driverCurrentStatus.save
	end

	def acceptRequest
		output = ""
		trip_request = ""
		driverRequest = DriverCurrentStatus.find_by(trip_request_id2: params[:trip_request_id2], driver_id2: session[:driver_id2])
		directions = ""
		if (!!driverRequest & (params[:acceptance_code] == "1") & (driverRequest.trip_status.to_s != "time_ran_out"))
			trip_request = TripRequest.find_by(trip_request_id2: params[:trip_request_id2])
			a = ActiveTrip.new(active_trip_id2: params[:trip_request_id2].to_s, driver_id2: session[:driver_id2].to_s, driver_connect_time: Time.now, status: 1, route_data: "")
			a.attributes=trip_request.as_json(only: [:user_id2, :trip_request_id2, :map_provider, :map_provider_url, :destination_street, :destination_city, :destination_state, :destination_postalcode, :destination_longitude, :destination_latitude, :map_provider_destination_id, :map_provider_destination_slug])
			a.save!
			driverRequest.reload
			trip_request.reload
			bearing = !!params[:bearing] ? params[:bearing].to_s : nil
			directions = Driver.get_directions(a.active_trip_id2, trip_request.pickup_longitude, trip_request.pickup_latitude, trip_request.destination_longitude, trip_request.destination_latitude, bearing)
			driverRequest.trip_status = "accepted"
		elsif (!!driverRequest & (params[:acceptance_code] == "0"))
			driverRequest.trip_status = "available"
		end
		while (!driverRequest.save!)
			driverRequest.save!
		end
		driverRequest.reload
		if driverRequest.trip_status.to_s == "accepted"
			output = "accepted!#{driverRequest.current_longitude},#{driverRequest.current_latitude},#{trip_request.pickup_longitude},#{trip_request.pickup_latitude},#{trip_request.destination_longitude},#{trip_request.destination_latitude}!#{directions}"
		else
			output = driverRequest.trip_status.to_s
		end
		render plain: output
	end

	def getDirections
		trip_request = TripRequest.find_by(trip_request_id2: params[:trip_request_id])
		bearing = !!params[:bearing] ? params[:bearing].to_s : nil
		directions = Driver.get_directions(nil, params[:longitude].to_s, params[:latitude].to_s, trip_request.pickup_longitude, trip_request.pickup_latitude, bearing )
		render plain: directions
	end

	def getSnappedCoordinates
		url = "http://router.project-osrm.org/nearest/v1/driving/#{params[:longitude].to_s},#{params[:latitude].to_s}"
		uri = URI.parse(url)
		connection = Net::HTTP.new(uri.host, uri.port)
		res = connection.get(uri.request_uri)
		render plain: res.body
	end

end
