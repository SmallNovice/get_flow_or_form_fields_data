class Tools
  def self.skylark_service
    @skylark_service ||= SkylarkService.new
  end

  def self.is_required?(presence)
    if presence == 'presence'
      '是'
    else
      '否'
    end
  end

  def self.all_forms_responses
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

  def self.all_flows_fields
    all_flows = []
    for i in 1..1000
      begin
        get_response = JSON.parse(skylark_service.query_flow(i))
        unless get_response['title'] == '流程' || get_response['title'] == '测试'
          get_response['vertices'].each do |vertice_fields|
            all_flows << { :title => get_response['title'], :id => get_response['id'],
                           :vertice_name => vertice_fields['name'], :vertice_fields => vertice_fields['fields'] }
          end
        end
      rescue
        next
      end
    end
    all_flows
  end

  def self.table_header
    ['名称', '类型', 'id', '字段名称', '字段映射名', '是否必填', '字段位置']
  end
end
