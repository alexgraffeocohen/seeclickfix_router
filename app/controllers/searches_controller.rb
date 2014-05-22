class SearchesController < ApplicationController

  def search
  end

  def show
    full_address = "#{params[:address]}, #{params[:city]}, #{params[:state]}"
    scf_location = APIParser.grab_location(full_address)

    if fields_missing?
      flash.now[:notice] = "Please fill in all fields"
      return render 'search' 
    elsif no_recent_issues_for(scf_location)
      flash.now[:notice] = "Sorry, there were no recent issues reported in this location."
      return render 'search'
    else
      update_dash_with(scf_location, full_address)
      redirect_to 'http://see-click-fix-dash.herokuapp.com/seeclickfix'
    end
  end

  private

  def fields_missing?
    params[:address].blank? || params[:city].blank? || params[:state].blank?
  end

  def no_recent_issues_for(address)
    open_issues = APIParser.find_issues(address, 'open')
    open_issues.blank?
  end

  def update_dash_with(address, full_address)
    open_issues = APIParser.find_issues(address, 'open')
    closed_issues = APIParser.find_issues(address, 'closed')
    acknowledged_issues = APIParser.find_issues(address, 'acknowledged')
    all_issues = open_issues + closed_issues + acknowledged_issues

    send_requests_for([open_issues, closed_issues, acknowledged_issues])
    update_location_for(full_address)
    fetch_categories_for(all_issues)
    generate_graph_for(address)
  end

  def fetch_categories_for(all_issues)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    category_hash = APIParser.map_categories(all_issues)
    Typhoeus.post("#{dash_url}/categories", body: { auth_token: 'seeclickfix', items: APIParser.generate_dash_hash(category_hash) }.to_json)
  end

  def generate_graph_for(address)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    data = APIParser.generate_graph_data(address)
    total_closed = 0
    data.each do |datum|
      total_closed += datum[:y]
    end
    Typhoeus.post("#{dash_url}/graph", body: { auth_token: 'seeclickfix', points: data, displayedValue: total_closed / data.count }.to_json)
  end

  def update_location_for(address)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    Typhoeus.post("#{dash_url}/welcome", body: { auth_token: 'seeclickfix', text: "#{address}" }.to_json)
  end

  def send_requests_for(data)
    dash_url = "http://see-click-fix-dash.herokuapp.com/widgets"
    data.each do |datum|
      status = datum.first["status"].downcase
      Typhoeus.post("#{dash_url}/#{status}", body: { auth_token: 'seeclickfix', current: datum.count }.to_json)
    end
  end

  # def update_dash(widget_name, )

end
