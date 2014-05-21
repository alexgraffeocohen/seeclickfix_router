class SearchesController < ApplicationController

  def search
  end

  def show
    if field_missing?
      flash[:notice] = "Please fill in all fields"
      return render 'search' 
    else
      full_address = "#{params[:address]}, #{params[:city]}, #{params[:state]}"
      update_dash_with_location(full_address)
    end
  end

  private

  def field_missing?
    !params[:address] && !params[:city] && !params[:state]
  end

  def update_dash_with_location(full_address)
    # location = get_lat_and_long(full_address)

    # Typhoeus.post("http://localhost:3030/widgets/open", body: {auth_token: 'seeclickfix', current: get_current_value(location, 'open')}.to_json)
    # Typhoeus.post("http://localhost:3030/widgets/closed", body: {auth_token: 'seeclickfix', current: get_current_value(location, 'closed')}.to_json)
    # Typhoeus.post("http://localhost:3030/widgets/acknowledged", body: {auth_token: 'seeclickfix', current: get_current_value(location, 'acknowledged')}.to_json)
  end

end
