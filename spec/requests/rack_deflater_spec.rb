require 'spec_helper'

describe Rack::Deflater, :type => :request do
	it "produces an identical eTag when content is identical" do
		get '/'
		expect(response.headers["Content-Encoding"]).to be_nil
		etag = response.headers["Etag"]
		content_length = response.headers["Content-Length"].to_i
		get '/'
		expect(response.headers["Etag"]).to eq etag
		expect(response.headers["Content-Length"].to_i).to eq content_length
	end
	
	it "produces an identical eTag whether content is deflated or not" do
		get '/'
		expect(response.headers["Content-Encoding"]).to be_nil
		etag = response.headers["Etag"]
		content_length = response.headers["Content-Length"].to_i
		get '/', {}, { "HTTP_ACCEPT_ENCODING" => "gzip" }
		expect(response.headers["Etag"]).to eq etag
		expect(response.headers["Content-Length"].to_i).not_to eq content_length
		expect(response.headers["Content-Encoding"]).to eq "gzip"
	end
end
