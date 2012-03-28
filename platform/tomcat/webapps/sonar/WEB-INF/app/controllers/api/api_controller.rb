#
# Sonar, entreprise quality control tool.
# Copyright (C) 2008-2012 SonarSource
# mailto:contact AT sonarsource DOT com
#
# Sonar is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# Sonar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with Sonar; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
#
require 'json'
require 'time'
class Api::ApiController < ApplicationController

  class ApiException < Exception
    attr_reader :code, :msg

    def initialize(code, msg)
      @code = code
      @msg = msg
    end
  end

  def text_not_supported
    "Not supported"
  end

  def xml_not_supported
    xml = Builder::XmlMarkup.new(:indent => 0)
    xml.instruct!
    xml.not_supported
  end

  def json_not_supported
    JSON({:not_supported => true})
  end

  def jsonp(json)
    text=((json.is_a? String) ? json : JSON(json))

    if params['callback']
      params['callback'] + '(' + text + ');'
    else
      text
    end
  end

  # deprecated. Use Api::Utils.format_datetime
  def format_datetime(datetime)
    Api::Utils.format_datetime(datetime)
  end

  # deprecated. Use Api::Utils.parse_datetime
  def parse_datetime(datetime_string, default_is_now=true)
    Api::Utils.parse_datetime(datetime_string, default_is_now)
  end

  def load_resource(resource_key, role=nil)
    resource=Project.by_key(resource_key)
    not_found("Resource not found: #{resource_key}") if resource.nil?
    access_denied if role && !has_role?(role, resource)
    resource
  end


  #
  #
  # Error handling is different than in ApplicationController
  #
  #

  def render_error(exception, status=500)
    message = exception.respond_to?('message') ? Api::Utils.exception_message(exception) : exception.to_s
    java_facade.logError("Fail to render: #{request.url}\n#{message}") if status==500
    respond_to do |format|
      format.json { render :json => error_to_json(status, message), :status => status }
      format.xml { render :xml => error_to_xml(status, message), :status => status }
      format.text { render :text => message, :status => status }
    end
  end

  def render_not_found(exception)
    message = exception.respond_to?('message') ? exception.message : exception.to_s
    render_error(message, 404)
  end

  def render_bad_request(exception)
    message = exception.respond_to?('message') ? exception.message : exception.to_s
    render_error(message, 400)
  end

  def render_access_denied
    render_error('Unauthorized', 401)
  end

  def render_success(message=nil)
    render_error(message, 200)
  end

  def error_to_json(status, message=nil)
    hash={:err_code => status}
    hash[:err_msg]=message if message
    jsonp(hash)
  end

  def error_to_xml(status, message=nil)
    xml = Builder::XmlMarkup.new(:indent => 0)
    xml.error do
      xml.code(status)
      xml.msg(message) if message
    end
  end


end

