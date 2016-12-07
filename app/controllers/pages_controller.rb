class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:regime]

  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def regime
    check_permission 'admin'
    @pauson = Entity.find(15032)
    render layout: "fullscreen"
  end

end
