class SearchesController < ApplicationController

  def search
  end

  def show
    query = params[:q]
    if !query.is_a? Integer || !query.length == 5
      flash[:notice] = "Please enter a valid zip code!"
      render 'search'
    end
  end


end
