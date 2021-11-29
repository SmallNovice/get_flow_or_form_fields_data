require 'csv'
require 'rest-client'
require 'jwt'
require_relative 'skylark_service'

class MappingCsv
  def self.csv
    CSV.open('./ceshi/all_forms.csv', 'w') do |writer|
      writer << ['流程名称', '类型', '流程id', '字段名称', '字段映射名', '是否必填', '字段位置']
      get_all_form_ids.each do |form_id|
        response_fields = JSON.parse(skylark_service.query_form(form_id))
        response_fields['fields'].each do |response_field|
          if response_field['title'] != '-'
            writer << [response_fields['title'], '表单', response_fields['id'], response_field['title'], response_field['identity_key'], is_required?(response_field['validations'][0]), '发起表单']
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

  def self.get_all_form_ids
    form_ids = []
    for i in 1..1000
      begin
        get_response = JSON.parse(skylark_service.query_form(i))
        unless get_response['title'] == '表单' || get_response['title'] == '测试'
          form_ids << i
        end
      rescue
        next
      end
    end
    form_ids
  end
end

MappingCsv.csv