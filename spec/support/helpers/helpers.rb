# frozen_string_literal: true

def parse_for_params(url)
  query = URI.parse(url).query

  params = {}
  query.split("&").each do |param|
    parts = param.split("=")
    params[parts[0]] = parts[1]
  end

  params
end
