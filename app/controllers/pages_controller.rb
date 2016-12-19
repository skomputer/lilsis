class PagesController < ApplicationController

  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def regime
    @pauson = Entity.find(15032)
    @schwarzman = Entity.find(14997)
    render layout: "fullscreen"
  end

  def the_trump_club
    @trump = Entity.find(15108)
    @graph = trump_network_graph
    render layout: "fullscreen"
  end

  private

  def trump_network_graph
    Rails.cache.fetch('trump_network_graph', expires_in: 2.hours) do
      NetworkGraph.new(15108, nil).graph
    end
  end

end
