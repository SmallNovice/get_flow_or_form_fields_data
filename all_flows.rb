require 'csv'
require 'rest-client'
require 'jwt'
require_relative 'skylark_service'
require_relative 'tools'
include Tools

class MappingCsv
  def csv
    CSV.open('./ceshi/all_flows.csv', 'w') do |writer|
      first = 1
      writer << table_header
      3.times do
        write_csv(get_flows_fields(first += 50), writer)
      end
    end
  end

  private

  def write_csv(all_flows_fields, writer)
    all_flows_fields.each_with_object([]) do |vertices_fields, vertices_fields_ids|
      vertices_fields[:vertice_fields].each do |need_field|
        if (vertices_fields_ids & [need_field['id']]).empty? && need_field['title'] != '-'
          vertices_fields_ids << need_field['id']
          basics_fields = [vertices_fields[:title], '流程', vertices_fields[:id], need_field['title'], need_field['identity_key'], is_required?(need_field['validations'][0])]
          if vertices_fields[:vertice_name] == '开始节点'
            writer << basics_fields + ['发起表单']
          else
            writer << basics_fields + ['回传字段']
          end
        end
      end
    end
  end
end

MappingCsv.new.csv