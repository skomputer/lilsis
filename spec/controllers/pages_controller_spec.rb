require 'rails_helper'

describe PagesController, type: :controller do

  it { should route(:get , '/partypolitics').to(action: 'partypolitics') } 
  it { should route(:get , '/regime').to(action: 'regime') } 
  
  describe 'partypolitics' do
    before { get :partypolitics }
    it { should render_template(:partypolitics) }
    it { should render_with_layout(:fullscreen) } 
  end
  
  describe 'regime' do
    before { get :regime }
    it { should render_template(:regime) }
    it { should respond_with(:success) }
  end

end
