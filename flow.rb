class MappingCsv
  require 'csv'
  require 'rest-client'
  require 'jwt'
  require_relative 'skylark_service'

  def self.csv
    CSV.open('./ceshi/flow.csv', 'w') do |writer|
      writer << ["流程名称", "类型", "流程id", "字段名称", "字段映射名", "是否必填", "字段位置"]
      get_all_flow_ids.each do |flow_id|
        response_fields = JSON.parse(skylark_service.query_flow(flow_id))
        writer << [response_fields['title'], "流程", response_fields['id'], '', '', '']
        response_fields["vertices"].each_with_object([]) do |response_field, vertices_fields|
          response_field["fields"].each do |need_field|
            if (vertices_fields & [need_field['id']]).empty? && need_field['title'] != '-'
              vertices_fields << need_field['id']
              if response_field['name'] == '开始节点'
                writer << [response_fields['title'], "流程", response_fields['id'], need_field['title'], need_field['identity_key'], is_required?(need_field['validations'][0]), "发起表单"]
              else
                writer << [response_fields['title'], "流程", response_fields['id'], need_field['title'], need_field['identity_key'], is_required?(need_field['validations'][0]), "回传字段"]
              end
            end
          end
        end
      end
    end
  end

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

  def self.get_all_flow_ids
    flow_ids = []
    for i in 1..1000
      begin
        get_response = JSON.parse(skylark_service.query_flow(i))
        unless get_response['title'] == '流程' || get_response['title'] == '测试'
          flow_ids << i
        end
      rescue
        next
      end
    end
    flow_ids
  end
end


MappingCsv.csv