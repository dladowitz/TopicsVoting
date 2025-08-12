require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'when country is present' do
      it { should validate_length_of(:country).is_equal_to(2) }
    end

    context 'when website is present' do
      it { should allow_value('http://example.com').for(:website) }
      it { should allow_value('https://example.com').for(:website) }
      it { should_not allow_value('not-a-url').for(:website) }
    end
  end
end
