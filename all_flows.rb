require 'csv'
require 'rest-client'
require 'jwt'
require_relative 'skylark_service'

class MappingCsv
  def self.csv
    all_flows_fields =
      self.get_all_flow_ids.each_with_object([]) do |flow_id, all_flows|
        get_response = JSON.parse(skylark_service.query_flow(flow_id.to_i))
        get_response['vertices'].each do |vertice_fields|
          all_flows << { :title => get_response['title'], :id => get_response['id'],
                         :vertice_name => vertice_fields['name'], :vertice_fields => vertice_fields['fields'] }
        end
      end
    
    CSV.open('./ceshi/all_flows.csv', 'w') do |writer|
      writer << ['流程名称', '类型', '流程id', '字段名称', '字段映射名', '是否必填', '字段位置']
      all_flows_fields.each_with_object([]) do |vertices_fields, vertices_fields_ids|
        vertices_fields[:vertice_fields].each do |need_field|
          if (vertices_fields_ids & [need_field['id']]).empty? && need_field['title'] != '-'
            vertices_fields_ids << need_field['id']
            if vertices_fields[:vertice_name] == '开始节点'
              writer << [vertices_fields[:title], '流程', vertices_fields[:id], need_field['title'], need_field['identity_key'], is_required?(need_field['validations'][0]), '发起表单']
            else
              writer << [vertices_fields[:title], '流程', vertices_fields[:id], need_field['title'], need_field['identity_key'], is_required?(need_field['validations'][0]), '回传字段']
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
