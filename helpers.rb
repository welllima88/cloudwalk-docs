module Helpers
  def link_to(name, url)
    "<a href='/#{I18n.locale}/#{url}'>#{name}</a>"
  end

  def toc_item(text)
    # Table of contents item
    "<a href='##{text.to_url}'>#{text}</a>"
  end

  def toc_header(text)
    # Table of contents header
    "<h3 class='anchor' id='#{text.to_url}'>#{toc_item(text)}</h3>"
  end

  def embed_posxml_code(gist_id)
    # Create the button
    markup = "<span id='copy-snippet-1' class='btn btn-small btn-clipboard'><span class='fa fa-clipboard'></span> #{I18n.t("copy")}</span>"

    # Create the hidden <pre> element that will contain the source code
    markup << "<pre data-display-element='#code-snippet-1' class='snippet hidden'>"
    markup << fetch_gist(gist_id)
    markup << "</pre>"

    # Create the <code> element that will receive the content of the
    # previous <pre> element, which will then apply the syntax highlight
    markup << "<pre><code id='code-snippet-1' data-language='html'></code></pre>"
  end

  def fetch_gist(gist_id)
    require 'open-uri'

    # All the gists are stored on the user posxml
    gist_path = "https://gist.githubusercontent.com/posxml/#{gist_id}/raw"

    begin
      res = open(gist_path)
      raise unless res.status[0] == "200"

      # Replace html symbols
      res.string.gsub("<", "&lt;").gsub(">", "&gt;")
    rescue
      "<!-- It was not possible to fetch this snippet -->\n\n#{gist_path}"
    end
  end

  def is_group_active?(group)
    "in" if group == request.path_info.split("/")[2]
  end

  def is_group_item_active?(group=nil, item=nil)
    if group == request.path_info.split("/")[2]
      return "active" if request.path_info.split("/").length == 3 && item.nil?
      return "active" if request.path_info.split("/").include? item
    end
  end

  def option_select(value, text, current=nil)
    selected = validate_option_value(value, current)
    "<option value=#{value}#{selected}>#{text}</option>"
  end

  def validate_option_value(value, current)
    ' selected' if value == current.to_s
  end

  def check_param(params, name, valid_options=nil)
    return "none" if params.empty?
    valid_options.member?(params[name]) ? params[name] : nil
  end

  def search
    require 'net/http'

    uri = URI.parse(URI.encode(build_search_url))
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(request)

    raise res.body unless res.code == "200"

    JSON.parse(res.body)
  rescue
    send_mail("Search error", "Could not perform search.\n\n#{$!.class}: #{$!.message}\n\nQuery: #{params[:query]}")
    return false
  end

  def build_search_url
    # http://domain.com/en?query=something&access_token=secret

    search_url = ENV["SEARCH_API_URL"].dup
    search_url << I18n.locale.to_s
    search_url << "?query=#{params[:query]}"
    search_url << "&access_token=#{ENV["SEARCH_API_TOKEN"].dup}"
  end

  def parse_search_results(response)
    markup = ""

    if response["results"].count > 0
      # Open a list
      markup = "<ul class='search-listing'>"

      # Iterate on entries
      response['results'].each do |entry|
        # Add a list item
        markup << "<li><a href='#{entry["url"]}'>#{entry["title"]}</a><p class='muted'>#{entry["description"]}</p></li>"
      end

      # Close the list
      markup << "</ul>"
    else
      # Not found
      markup = "<br/><p>#{I18n.t("search.success.no_results")}</p>"
    end
    markup
  end

  def send_mail(subject, body)
    Pony.mail :to => ENV["ADMIN_CONTACT_EMAIL"].dup,
              :from => "docs@cloudwalk.io",
              :subject => subject,
              :body => body
  end
end
