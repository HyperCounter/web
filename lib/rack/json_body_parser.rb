require 'rack/contrib/post_body_content_type_parser'

module Rack
  class JsonBodyParser < ::Rack::PostBodyContentTypeParser
    def call(env)
      begin
        if ::Rack::Request.new(env).media_type == APPLICATION_JSON && !(body = env[POST_BODY].read.strip).empty?
          env[POST_BODY].rewind # somebody might try to read this stream
          env.update(FORM_HASH => JSON.parse(body), FORM_INPUT => env[POST_BODY])
        end
        @app.call(env)
      rescue JSON::ParserError => ex
        [400, { 'Content-Type' => 'application/json' }, [{message: ex.to_s}.to_json]]
      rescue JSON::GeneratorError => ex # - source sequence is illegal/malformed utf-8
        [400, { 'Content-Type' => 'application/json' }, [{message: ex.to_s}.to_json]]
      end
    end
  end
end
