class SearchesController < ApplicationController

  def search
  end

  def show
    if !params[:address] && !params[:city] && !params[:state]
      flash[:notice] = "Please fill in all fields"
      return render 'search' 
    else
      full_address = "#{params[:address]}, #{params[:city]}, #{params[:state]}"
      scf_location = APIParser.grab_location(full_address)
      update_dash_with(scf_location)
      redirect_to 'http://see-click-fix-dash.herokuapp.com/seeclickfix'
    end
  end

  private

  def update_dash_with(address)
    open_issues = APIParser.find_issues(address, 'open')
    closed_issues = APIParser.find_issues(address, 'closed')
    acknowledged_issues = APIParser.find_issues(address, 'acknowledged')

    send_requests_for([open_issues, closed_issues, acknowledged_issues])
  end

  def send_requests_for(data)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    data.each do |datum|
      status = datum.first["status"].downcase
      Typhoeus.post("#{dash_url}/#{status}", body: {auth_token: 'YOUR_AUTH_TOKEN', current: datum.count}.to_json)
    end
  end

end
