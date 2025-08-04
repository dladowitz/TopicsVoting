require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#sanitize_url' do
    context 'with blank input' do
      it 'returns nil for nil' do
        expect(helper.sanitize_url(nil)).to be_nil
      end
    end

    context 'with invalid URLs' do
      it 'returns nil for malformed URLs' do
        expect(helper.sanitize_url('not a url')).to be_nil
      end

      it 'returns nil for URLs with invalid characters' do
        expect(helper.sanitize_url('http://example.com/path with spaces')).to be_nil
      end
    end

    context 'with valid http(s) URLs' do
      it 'returns the URL for http scheme' do
        url = 'http://example.com'
        expect(helper.sanitize_url(url)).to eq(url)
      end

      it 'returns the URL for https scheme' do
        url = 'https://example.com'
        expect(helper.sanitize_url(url)).to eq(url)
      end

      it 'returns the URL for complex paths' do
        url = 'https://example.com/path/to/resource?param=value#fragment'
        expect(helper.sanitize_url(url)).to eq(url)
      end

      it 'returns the URL for subdomains' do
        url = 'https://subdomain.example.com'
        expect(helper.sanitize_url(url)).to eq(url)
      end
    end
  end
end
