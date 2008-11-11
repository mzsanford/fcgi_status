

module FcgiStatus
  def self.included(controller)
    controller.class_eval do
      around_filter :with_process_title unless RAILS_ENV == 'test'
    end
  end

  def with_process_title
    start_process
    yield
  ensure
    finish_process
  end

  private

  def start_process
    $total_processed_requests ||= 0
    $start_processing_time ||= Time.now
    @started = true
    $0 = "#{process_title}: running #{current_job}"
  end

  def finish_process
    $total_processed_requests += 1
    @started = false
    $0 = "#{process_title}: last job: #{current_job}"
  end

  def process_title
    $original_process_title ||= "dispatch.fcgi"
    "#{$original_process_title} (#{$total_processed_requests}/#{display_time})"
  end

  def current_job
    if self.respond_to?('fcgi_key')
      key = self.fcgi_key
    else
      key = request.env['REQUEST_PATH']
    end
    "#{self.class}##{action_name} #{request.env['REQUEST_METHOD']} (#{key})"
  end

  def display_time
      secs = (Time.now - $start_processing_time).to_i
      days, secs = secs.abs.divmod(60 * 60 * 24)
      hours,secs = secs.abs.divmod(60 * 60)
      mins, secs = secs.abs.divmod(60)
      rtn =  ""
      rtn << "%dd" % [days] if days  != 0
      rtn << "%dh" % [hours] if hours != 0
      rtn << "%dm" % [mins] if mins  != 0
      rtn << "%02.2fs" % [secs]
      rtn
  end
end