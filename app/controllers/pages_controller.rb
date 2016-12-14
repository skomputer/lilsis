class PagesController < ApplicationController

  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def regime
    @pauson = Entity.find(15032)
    render layout: "fullscreen"
  end

end
