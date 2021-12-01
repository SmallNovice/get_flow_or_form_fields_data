module Tools
  module_function

  def skylark_service
    @skylark_service ||= SkylarkService.new
  end

  def is_required?(presence)
    if presence == 'presence'
      '是'
    else
      '否'
    end
  end

  def all_forms_responses
    form_response = []
    for i in 1..1000
      begin
        get_response = JSON.parse(skylark_service.query_form(i))
        unless get_response['title'] == '表单' || get_response['title'] == '测试'
          form_response << get_response
        end
      rescue
        next
      end
    end
    form_response
  end

  def get_flows_fields(first, logger)
    all_flows = []
    for i in (first - 50)..first
      retryable(logger) do
        logger.info "The current flow location is #{i} "
        get_response = JSON.parse(skylark_service.query_flow(i))
        next if get_response['title'] == '流程' || get_response['title'] == '测试'
        get_response['vertices'].each do |vertice_fields|
          all_flows << { :title => get_response['title'], :id => get_response['id'],
                         :vertice_name => vertice_fields['name'], :vertice_fields => vertice_fields['fields'] }
        end
      end
    end
    all_flows
  end

  def table_header
    %w(名称 类型 id 字段名称 字段映射名 是否必填 字段位置)
  end

  def retryable(logger, options = {})
    opts = { tries: 3, on: Exception }.merge(options)
    retry_exception, retries = opts[:on], opts[:tries]
    begin
      yield
    rescue retry_exception => e
      if (retries -= 1) >= 0
        logger.info "not find flow/form,#{e.inspect}. number of retries remaining: #{retries}"
        retry
      end
    end
  end
end
