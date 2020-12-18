# coding: utf-8

class MastodonAPI
  def initialize(params)
    if params[:domain]
      @domain = params[:domain]
    else
      raise 'ドメインが指定されていません'
    end

    if params[:read_access_token]
      @read_access_token = params[:read_access_token]
    else
      raise '読み取り用アクセストークンが指定されていません'
    end

    if params[:write_access_token]
      @write_access_token = params[:write_access_token]
    else
      raise '書き込み用アクセストークンが指定されていません'
    end
  end

  def verify_credentials
    do_get(verify_credentials_url, {}, @read_access_token)
  end

  def account_statuses(account_id)
    do_get(account_statuses_url(account_id), { exclude_reblogs: 'true' }, @read_access_token)
  end
  
  def post_status(status, visibility)
    visibility ||= 'unlisted'
    do_post(post_status_url, { access_token: @write_access_token, status: status, visibility: visibility })
  end

  private
  def verify_credentials_url
    "https://#{@domain}/api/v1/accounts/verify_credentials"
  end

  def account_statuses_url(account_id)
    "https://#{@domain}/api/v1/accounts/#{account_id}/statuses"
  end

  def post_status_url
    "https://#{@domain}/api/v1/statuses"
  end

  def do_get(url, params, access_token)
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port).tap do |obj|
     obj.use_ssl = true
     obj.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    request["Authorization"] = "bearer #{access_token}"
    JSON.parse(http.request(request).body)
  end

  def do_post(url, params)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port).tap do |obj|
      obj.use_ssl = true
      obj.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data(params)
    http.request(request)
  end
end
