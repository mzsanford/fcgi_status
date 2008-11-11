
RAILS_ENV = 'test'

require 'test/unit'
require 'rubygems'
require 'action_controller'
require 'action_controller/test_process'
require 'fcgi_status'

class FcgiStatusTest < Test::Unit::TestCase
  include FcgiStatus
  attr_accessor :request, :action_name

  def setup
    super
    @controller  = DummyController.new
    @request     = @controller.request
  end

  def test_active_display
    start_process
    assert_match /running/, $0
    # Contains requests/secs (no min, hr, day)
    assert_match /\d+\/\d+\.\d\ds/, $0
    finish_process
  end

  def test_finish_display
    start_process
    sleep(1)
    finish_process
    assert_match /last job/, $0
    # Contains requests/secs (no min, hr, day)
    assert_match /\d+\/\d+\.\d\ds/, $0
  end
end

class DummyRequest
  attr_accessor :symbolized_path_parameters

  def initialize
    @get = true
    @params = {}
    @symbolized_path_parameters = { :controller => 'foo', :action => 'bar' }
  end

  def get?
    @get
  end

  def post
    @get = false
  end

  def relative_url_root
    ''
  end

  def env
    {}
  end

  def params(more = nil)
    @params.update(more) if more
    @params
  end
end

class DummyController
  attr_reader :request
  attr_accessor :controller_name

  def initialize
    @request = DummyRequest.new
    @url = ActionController::UrlRewriter.new(@request, @request.params)
  end

  def params
    @request.params
  end

  def url_for(params)
    @url.rewrite(params)
  end
end