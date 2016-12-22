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

  def trump_network
    render json: trump_entity_network
  end

  private

  def trump_entity_network
    one_degree_ids = Link.entity2_ids(15108)
    Link.entity_network(15108, true).map do |e|
      info = e.attributes.slice('id', 'name', 'blurb')
      if one_degree_ids.include? e.id
        
      else
      end
    end
    # Rails.cache.fetch('trump_entity_network', expires_in: 4.hours) do
    # end
  end

  def trump_network_graph
    Rails.cache.fetch('trump_network_graph', expires_in: 2.hours) do
      NetworkGraph.new(15108, nil).graph
    end
  end

end
