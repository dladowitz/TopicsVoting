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

  describe '#format_with_commas' do
    context 'with small numbers' do
      it 'returns the number as string for numbers less than 1000' do
        expect(helper.format_with_commas(123)).to eq('123')
        expect(helper.format_with_commas(999)).to eq('999')
      end
    end

    context 'with numbers 1000 and above' do
      it 'adds commas for thousands' do
        expect(helper.format_with_commas(1000)).to eq('1,000')
        expect(helper.format_with_commas(11145)).to eq('11,145')
        expect(helper.format_with_commas(123456)).to eq('123,456')
      end

      it 'adds commas for millions' do
        expect(helper.format_with_commas(1000000)).to eq('1,000,000')
        expect(helper.format_with_commas(1234567)).to eq('1,234,567')
      end
    end

    context 'with string input' do
      it 'formats string numbers correctly' do
        expect(helper.format_with_commas('11145')).to eq('11,145')
        expect(helper.format_with_commas('123456')).to eq('123,456')
      end
    end

    context 'with zero' do
      it 'returns zero as string' do
        expect(helper.format_with_commas(0)).to eq('0')
      end
    end
  end
end
