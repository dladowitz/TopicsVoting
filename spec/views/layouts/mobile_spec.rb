require 'rails_helper'

RSpec.describe 'layouts/mobile', type: :view do
  it 'includes favicon links' do
    render template: 'layouts/mobile'

    expect(rendered).to include("href='/favicon.ico?v=4'")
    expect(rendered).to include("href='/icon.png?v=4'")
    expect(rendered).to include("href='/icon.svg?v=4'")
    expect(rendered).to include('apple-touch-icon')
  end
end
