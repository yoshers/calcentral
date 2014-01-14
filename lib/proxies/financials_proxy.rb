class FinancialsProxy < BaseProxy

  include ClassLogger

  APP_ID = "CFV"

  def initialize(options = {})
    super(Settings.financials_proxy, options)
  end

  def get
    request("/student/#{lookup_student_id}", "financials")
  end

  def request(path, vcr_cassette, params = {})
    self.class.fetch_from_cache(@uid) do
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #@uid failed, cannot call CFV API path #{path}"
        return {
          body: "CalCentral's My Finances tab is only available for current or recent UC Berkeley students. If you are seeing this message, it is because CalCentral did not receive any CARS data for your account. If you believe that you have received this message in error, please use the Feedback link below to tell us about the problem.",
          status_code: 400
        }
      else
        url = "#{Settings.financials_proxy.base_url}#{path}"
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"
        begin
          response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {match_requests_on: [:method, :path]}) {
            HTTParty.get(
              url,
              digest_auth: {username: Settings.financials_proxy.username, password: Settings.financials_proxy.password}
            )
          }
          if response.code >= 400
            logger.error "Connection failed: #{response.code} #{response.body}; url = #{url}"
            if response.code == 404
              body = "My Finances did not receive any CARS data for your account. If you are a current or recent student, and you feel that you've received this message in error, please try again later. If you continue to see this error, please use the feedback link below to tell us about the problem."
            else
              body = "My Finances is currently unavailable. Please try again later."
            end
            return {
              body: body,
              status_code: response.code
            }
          end

          logger.debug "Remote server status #{response.code}; url = #{url}"
          {
            body: JSON.parse(response.body),
            status_code: response.code
          }
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
          logger.error "Connection to url #{url} failed: #{e.class} #{e.message}"
          {
            body: "My Finances is currently unavailable. Please try again later.",
            status_code: 503
          }
        end
      end
    end
  end
end
