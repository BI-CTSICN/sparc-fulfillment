class ProtocolsController < ApplicationController
  respond_to :json, :html
  def index
    @protocols = Protocol.all
    respond_with @protocols
  end

  def show
    @protocol = Protocol.find(params[:id])
  end

end
