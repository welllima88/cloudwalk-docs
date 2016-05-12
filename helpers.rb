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

  def html_escape(html)
    html.nil? || html.empty? ? "" : CGI.escapeHTML(html)
  end

  def send_mail(subject, body)
    Pony.mail :to => ENV["ADMIN_CONTACT_EMAIL"].dup,
              :from => "docs@cloudwalk.io",
              :subject => subject,
              :body => body
  end
end
