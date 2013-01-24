class PagesController < ApplicationController
  def show
    render params[:id].gsub('-','_')
  end
end
